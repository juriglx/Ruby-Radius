require '../lib/packet.rb'


describe Radius::Packet do

  it "should parse the packet code" do
    data = [4].pack("C")

    packet = Radius::Packet.new(data, "secret")

    packet.code.should == "Accounting-Request"
    
  end



end