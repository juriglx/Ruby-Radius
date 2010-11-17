require 'lib/dictionary.rb'

describe Radius::Dictionary do

  before(:each) do
    content = "ATTRIBUTE User-Name 1 string\nATTRIBUTE	Service-Type 6 integer\nVALUE Service-Type Login-User 1"
    File.should_receive(:open).with("dictionary", "r").and_return(content)

    @dictionary = Radius::Dictionary.new("dictionary")
  end

  it "should provide lookup for attribute id's" do
    @dictionary.lookup(:attr_id => 1).should == {:attr_id => 1, :name => "User-Name", :type => "string"}
  end

  it "should provide lookup for attribute names" do
    @dictionary.lookup(:name => "User-Name").should == {:attr_id => 1, :name => "User-Name", :type => "string"}
  end

  it "should provide lookup for enumerated values" do
    @dictionary.lookup(:attr_id => 6, :value => 1).should == {:attr_id => 6, :name => "Service-Type", :type => "integer", :value => "Login-User"}
  end

end