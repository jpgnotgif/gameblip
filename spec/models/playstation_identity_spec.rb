require File.dirname(__FILE__) + '/../spec_helper'

describe PlaystationIdentity do
  before do
    @user = users(:josephpgutierrez)
    @category = categories(:ps3_custom)
    @gamer_identity_attributes = Factory.attributes_for(:gamer_identity)
    @playstation_identity_attributes = @gamer_identity_attributes.merge(:user_id => @user.id, :category_id => @category.id) 
    @playstation_identity = Factory.build(:playstation_identity, @playstation_identity_attributes)
    @valid_xml = File.open(File.join(RAILS_ROOT, "spec/files/xml/psn/geek_at_home/complete.xml"), "r") { |file| file.read }
    @invalid_xml = File.open(File.join(RAILS_ROOT, "spec/files/xml/psn/invalid/profile.xml"), "r") { |file| file.read }
    @url = AppConfig.instance_variable_get(:@config).psn_api.url
    @profile = AppConfig.instance_variable_get(:@config).psn_api.profile
  end

  it "should save" do
    Net::HTTP.expects(:get).with(URI.parse(@url + @playstation_identity.name)).returns(@valid_xml)
    @playstation_identity.save.should be_true
    @user.identities.count.should == 1
    GamerIdentity.should have(1).record
  end

  it "should require valid psn id" do
    Net::HTTP.expects(:get).at_least_once.with(URI.parse(@url + @playstation_identity.name)).returns(@invalid_xml)
    @playstation_identity.save.should be_false
    @playstation_identity.should have(1).error
    @playstation_identity.errors.full_messages.should include("PSN ID was not found. Please ensure that the id is correct")
    GamerIdentity.should have(:no).records
  end 

  it "should raise exception due to invalid API request" do
    Net::HTTP.expects(:get).raises(SocketError)
    @playstation_identity.save.should be_false
    @playstation_identity.should have(2).errors
    @playstation_identity.errors.full_messages.should include("An error occurred in the system. Please try again later.")
    @playstation_identity.errors.full_messages.should include("PSN ID was not found. Please ensure that the id is correct")
  end
end
