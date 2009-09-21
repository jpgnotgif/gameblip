require File.dirname(__FILE__) + '/../spec_helper'

describe XboxIdentity do
  before :each do
    @user = users(:josephpgutierrez)
    @category = categories(:xbox360_pro)
    @gamer_identity_attributes = Factory.attributes_for(:gamer_identity)
    @xbox_identity_attributes = @gamer_identity_attributes.merge(:user_id => @user.id, :category_id => @category.id)
    @xbox_identity = Factory.build(:xbox_identity, @xbox_identity_attributes)
    @valid_xml = File.open(File.join(RAILS_ROOT, "spec/files/xml/xbox_live", "jpgnotgif.xml"), "r") { |f| f.read }
    @invalid_xml = File.open(File.join(RAILS_ROOT, "spec/files/xml/xbox_live", "invalid_request.xml"), "r") { |f| f.read }
    @url = AppConfig.instance_variable_get(:@config).xbox_api.url
  end

  it "should save" do
    Net::HTTP.expects(:get).once.with(URI.parse(@url + @xbox_identity.name)).returns(@valid_xml)
    @xbox_identity.save.should be_true
    @user.identities.count.should == 1
    GamerIdentity.should have(1).record
  end

  it "should require valid gamertag" do
    Net::HTTP.expects(:get).at_least_once.with(URI.parse(@url + @xbox_identity.name)).returns(@invalid_xml)
    @xbox_identity.save.should be_false
    @xbox_identity.should have(1).error_on(:gamertag)
    @user.identities.count.should == 0
    GamerIdentity.should have(:no).records  
  end

  it "should raise exception due to invalid API request" do
    Net::HTTP.expects(:get).once.raises(SocketError)
    @xbox_identity.save.should be_false
    @xbox_identity.should have(1).errors
    @xbox_identity.errors.full_messages.should include("An error in the system occurred. Please try again later.")
  end

end
