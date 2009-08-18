require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  before do
    @xml = File.open(File.join(RAILS_ROOT, "spec/files/xml/xbox_live", "jpgnotgif.xml"), "r") { |f| f.read }
    @url = AppConfig.instance_variable_get(:@config).xbox_api.url
    @user = users(:josephpgutierrez)
    @xbox_console_user = Factory.build(:xbox_console_user, {:user => @user})
    Net::HTTP.expects(:get).with(URI.parse(@url + @xbox_console_user.gamertag)).returns(@xml)
    @xbox_console_user.save
    @activity = Factory.build(:activity, {:avatar_id => @xbox_console_user.id, :avatar_type => @xbox_console_user.class.name})
  end

  it "should save" do
    lambda {
      @activity.save.should be_true
      @xbox_console_user.activities.count.should == 1
    }.should change(Activity, :count).by(1)
  end

  it "requires non-blank description" do
    lambda {
      @activity.description = ""
      @activity.save.should be_false
      @activity.errors.on(:description).should be_true
      @xbox_console_user.activities.count.should == 0
    }.should_not change(Activity, :count).by(1)
  end

  it "requires 180 character limit on description" do
    lambda {
      @activity.description = "This is an extremely long description and it exceeds the total number of characters allowed. In order to make this description longer, I have to add more characters. Here are some more characters"
      @activity.save.should be_false
      @activity.errors.on(:description).should be_true
      @xbox_console_user.activities.count.should == 0
    }.should_not change(Activity, :count).by(1)
  end

  it "requires a valid avatar id" do
    lambda {
      @activity.avatar_id = nil
      @activity.save.should be_false
      @activity.errors.on(:avatar).should be_true
      @activity.errors.full_messages.include?("Avatar must be associated with an activity").should be_true
    }.should_not change(Activity, :count).by(1)
  end

  it "requires a valid avatar type" do
    lambda {
      @activity.avatar_type = "InvalidType"
      @activity.save.should be_false
      @activity.errors.on(:avatar).should be_true
      @activity.errors.full_messages.include?("Avatar must be associated with an activity").should be_true
    }.should_not change(Activity, :count).by(1)
  end

  it "should get recent activities" do
    2.times { |n| Factory(:activity, {:description => "This is activity # #{n}", :avatar => @xbox_console_user, :created_at => Time.now - 7.days})}
    4.times { |n| Factory(:activity, {:description => "This is a recent activity, Number #{n} to be exact.", :avatar => @xbox_console_user})}
    Activity.recent.count.should == 4
  end

end
