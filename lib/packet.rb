module Radius
  require 'digest/md5'

  class Packet

    CODES = {
      1 => 'Access-Request',
      2 => 'Access-Accept',
      3 => 'Access-Reject',
      4 => 'Accounting-Request',
      5 => 'Accounting-Response',
      11 => 'Access-Challenge',
      12 => 'Status-Server',
      13 => 'Status-Client'
    }

    attr_accessor :identifier
    attr_accessor :length
    attr_accessor :raw_data
    attr_accessor :secret
    attr_accessor :authenticator

    def initialize(args = nil)
      @secret = args[:secret] || "secret" 
      @attributes = {}

      unpack(args[:data]) unless args[:data].nil?
      make_response(args[:request]) unless args[:request].nil?
    end

    def code
      return CODES[@code] unless CODES[@code].nil?
      "Unknown Code"
    end

    def attributes(dictionary = nil)
      attr = {}

      if dictionary.nil?
        @attributes.each {|attr_id, attr_value|
          attr[attr_id] = attr_value.unpack("H*")       
        }

      else
        @attributes.each {|attr_id, attr_value|
          entry = dictionary.lookup(:attr_id => attr_id, :value => attr_value)
          attr[entry[:name]] = entry[:value] || attr_value
        }
      end

      attr
    end

    def to_s(dictionary = nil)
      s = "\n---- Radius Packet ----\n"
      s << "#{code} (id = #{@identifier}, length = #{@length})\n"
      attributes(dictionary).each {
        |key, value| s << "#{key.to_s} : #{value.to_s}\n"
      }
      s
    end

    def valid?
      auth = Digest::MD5.digest([@code, @identifier, @length,
                                 @raw_attributes, @secret].pack("CCnx16a*a*"))
      return auth == @authenticator
    end

    private

    def make_response(request)
      case request.code

        when "Accounting-Request"

          @code = 5
          @identifier = request.identifier
          @length = 20 # 16 auth, 2 len, 1 code, 1 id
          @raw_data = [@code, @identifier, @length].pack("CCn")
          @authenticator = Digest::MD5.digest(@raw_data +
                  [request.authenticator, request.secret].pack("a16a*"))
          @raw_data << [@authenticator].pack("a*")

      end
    end

    def unpack(data)
      @raw_data = data
      @code, @identifier, @length, @authenticator, @raw_attributes = @raw_data.unpack("CCna16a*")

      attributes = @raw_attributes
      while attributes.length > 0

        attr_length = attributes.unpack("xC")[0].to_i
        attr_id, attr_value = attributes.unpack("Cxa#{attr_length - 2}")
        attr_id = attr_id.to_i

        @attributes[attr_id] = attr_value
        attributes = attributes[attr_length..-1]
      end
    end

  end
end