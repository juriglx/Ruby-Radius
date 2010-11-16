#!/usr/bin/env ruby
require 'rubygems'
require 'eventmachine'
require 'lib/packet'
require 'lib/dictionary-BACKUP.rb-BACKUP'
 
class RadiusServer < EM::Connection
 
 def receive_data(data)
	dict = Radius::Dictionary.new("./dictionaries/dictionary")

 #	radiusPacket = Radius::Packet.new(dict, "secret")
 	puts data
	radiusPacket = Radius::Packet.unpack(dict, data, "secret")

  puts	radiusPacket.to_s()+"\n\n"
  send_data radiusPacket.get_accounting_response_packet
 end
end
 
 
EM.run do
 host = '0.0.0.0'
 port = 1813
 EM.epoll
 EM.open_datagram_socket host, port, RadiusServer do | connection |
 end
end
