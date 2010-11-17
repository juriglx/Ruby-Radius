require 'lib/packet.rb'
require 'lib/dictionary.rb'
require 'rspec'


describe Radius::Packet do

  before(:all) do
#   Accounting-Request, length = 84, id = 0
#   Acct-Status-Type = Accounting-On
#	Acct-Authentic = RADIUS
#	NAS-IP-Address = 10.0.5.7
#	NAS-Identifier = "pae-test-1"
#	Called-Station-Id = "00-0B-6B-4F-83-4A:aaa-test"
#	Acct-Terminate-Cause = NAS-Reboot
           #  1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
    data = ["04000054565bc8a5439c6443278a6368783d1a8b" +
            "2806000000072d060000000104060a000507200c" +
            "7061652d746573742d311e1c30302d30422d3642" +
            "2d34462d38332d34413a6161612d746573743106" +
            "0000000b"].pack("H*")

    @dictionary = Radius::Dictionary.new("dictionaries/dictionary")
    @packet = Radius::Packet.new(:secret => "secret", :data => data)
  end

  it "should parse the packet code" do
    @packet.code.should == "Accounting-Request"
  end

  it "should parse the identifier" do
    @packet.identifier.should == 0
  end

  it "should parse the packet length" do
    @packet.length.should == 84
  end

  it "should parse the attributes" do
    @packet.attributes.length.should == 6
  end

  it "can be checked if it is valid" do
    @packet.valid?.should == true
  end

  it "should parse the authenticator" do
    @packet.authenticator.length.should == 16
  end

  it "should can generate a response packet" do
    response = Radius::Packet.new(:request => @packet)
    response.code.should == "Accounting-Response"
    response.identifier.should == @packet.identifier
  end

end