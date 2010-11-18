

module Radius

  class Dictionary

    def initialize(dictionary_file)
      @dictionary = {0 => {:name => "RFC"}}

      load(dictionary_file)
    end

    def load(dictionary_file)

      vendor_id = 0

      File.open(dictionary_file, "r").each_line do |line|

        next if line =~ /^\#/ # discard comments
        next if (tokens = line.split(/\s+/)) == []

        case tokens[0].upcase
          when "ATTRIBUTE"

            _, name, attr_id, type = tokens
            entry = {:attr_id => attr_id.to_i, :name => name, :type => type}

            @dictionary[vendor_id][attr_id.to_i] = entry
            @dictionary[vendor_id][name] = entry

          when "VALUE"
            _, attr_name, value_name, value_id = tokens
            entry = {:value_id => value_id.to_i, :name => value_name}

            values = @dictionary[vendor_id][attr_name][:values] || {}
            values[value_id.to_i] = entry
            values[value_name] = entry

            @dictionary[vendor_id][attr_name][:values] = values          
        end

      end

    end


    # recognizes the named arguments:
    # * vendor_id - defaults to 0
    # * attr_id - the numeric id of the attribute to resolve
    # * name - the textual representation of the the attribute
    # * value - the unparsed value of an attribute
    def lookup(args)

      vendor_id = args[:vendor_id] || 0
      selector = args[:attr_id] || args[:name]

      raise "missing selector" if selector.nil?

      entry = @dictionary[vendor_id][selector]
      return entry if entry.nil?

      entry[:value] = resolve_value(entry, args[:value]) unless args[:value].nil?
      entry

    end

    private

    def resolve_value(entry, value)

      type = entry[:type]
      return value.unpack("H*") if type.nil?

      case type
        when "string"
          return value
        when "date", "time"
          return value.unpack("N")[0]
        when "integer"
          v = value.unpack("N")[0]
          return v if entry[:values].nil?
          enum_v = entry[:values][v]
          return enum_v unless enum_v.nil?
          return v
        when "ipaddr"
          return inet_ntoa(value.unpack("N")[0])
        else
          # Fallback
          return value.unpack("H*")
      end
    end

    def inet_ntoa(iaddr)
      return(sprintf("%d.%d.%d.%d", (iaddr >> 24) & 0xff, (iaddr >> 16) & 0xff,
                     (iaddr >> 8) & 0xff, (iaddr) & 0xff))
    end

  end

end