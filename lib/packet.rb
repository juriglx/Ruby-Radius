require '../lib/dictionary.rb'

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

    def initialize(data, secret)
      @secret = secret
      @raw_data = data

      unpack(data)
    end

    def code
      CODES[@code]
    end

    private

    def unpack(data)

      @code, _ = data.unpack("C")

    end

  end
end