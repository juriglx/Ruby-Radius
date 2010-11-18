

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
      resolve_value(entry, args[:value]) unless args[:value].nil?
      entry

    end

    private

    def resolve_value(entry, value)

      if entry[:type] == "ipaddr"
        entry[:value] = inet_ntoa(value.unpack("N")[0])
      end

      return if entry[:values].nil?

      value = value.unpack("N")[0]

      values = entry.delete(:values)
      entry[:value] = values[value][:name]
    end

    def inet_ntoa(iaddr)
      return(sprintf("%d.%d.%d.%d", (iaddr >> 24) & 0xff, (iaddr >> 16) & 0xff,
                     (iaddr >> 8) & 0xff, (iaddr) & 0xff))
    end

  end

end