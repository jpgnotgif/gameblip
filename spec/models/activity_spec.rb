require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  before do
    @xml = File.open(File.join(RAILS_ROOT, "spec/files/xml/xbox_live", "jpgnotgif.xml"), "r") { |f| f.read }
    @url = AppConfig.instance_variable_get(:@config).xbox_api.url
    @user = users(:josephpgutierrez)
    @gamer_identity_attributes = Factory.attributes_for(:gamer_identity).merge(:user_id => @user.id)
    @xbox_identity = Factory.build(:xbox_identity, @gamer_identity_attributes)
    Net::HTTP.expects(:get).with(URI.parse(@url + @xbox_identity.name)).returns(@xml)
    @xbox_identity.save!
    @activity = Factory.build(:activity, {:avatar_id => @xbox_identity.id, :avatar_type => @xbox_identity.type})
  end

  it "should save" do
    @activity.save.should be_true
    @xbox_identity.activities.should have(1).record
    Activity.should have(1).record
  end

  it "requires non-blank description" do
    @activity.description = ""
    @activity.save.should be_false
    @activity.should have(1).error_on(:description)
    @xbox_identity.activities.should have(:no).record
    Activity.should have(:no).record
  end

  it "requires 180 character limit on description" do
    @activity.description = "This is an extremely long description and it exceeds the total number of characters allowed. In order to make this description longer, I have to add more characters. Here are some more characters"
    @activity.save.should be_false
    @activity.errors.on(:description).should be_true
    @xbox_identity.activities.should have(:no).record
    Activity.should have(:no).record
  end

  it "requires a valid avatar id" do
    @activity.avatar_id = nil
    @activity.save.should be_false
    @activity.errors.on(:avatar).should be_true
    @activity.errors.full_messages.should include("Avatar must be associated with an activity")
    @xbox_identity.activities.should have(:no).record
    Activity.should have(:no).record
  end

  it "requires a valid avatar type" do
    @activity.avatar_type = "InvalidType"
    @activity.save.should be_false
    @activity.should have(1).error_on(:avatar)
    @activity.errors.full_messages.should include("Avatar must be associated with an activity")
    Activity.should have(:no).record
  end

  it "should get recent activities" do
    2.times { |n| Factory(:activity, {:description => "This is activity # #{n}", :avatar => @xbox_identity, :created_at => Time.now - 7.days})}
    4.times { |n| Factory(:activity, {:description => "This is a recent activity, Number #{n} to be exact.", :avatar => @xbox_identity})}
    Activity.recent.count.should == 4
  end

end
