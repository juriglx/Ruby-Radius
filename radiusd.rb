#!/usr/bin/env ruby
require 'rubygems'
require 'eventmachine'
require 'lib/packet'
require 'lib/dictionary'
 
class RadiusServer < EM::Connection
 
 def receive_data(data)

    # parse the dictionary
    # TODO: should not be done on every packet
	dict = Radius::Dictionary.new("./dictionaries/dictionary")

    # parse the packet
    in_packet = Radius::Packet.new(:secret => "secret", :data => data)


    if in_packet.code == "Accounting-Request" and in_packet.valid?

      # do something with the request
      puts in_packet.to_s(dict)

      # generate the response
      out_packet = Radius::Packet.new(:request => in_packet)
      puts out_packet.to_s(dict)

      # send the response
      send_data(out_packet.raw_data)
    end
   
 end
end
 
 
EM.run do
 host = '0.0.0.0'
 port = 1813
 EM.epoll
 EM.open_datagram_socket host, port, RadiusServer do | connection |
 end
end
