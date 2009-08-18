require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  before do
    @user = users(:josephpgutierrez)
    @xbox_console_user = Factory(:xbox_console_user, {:user => @user})
    @activity = Factory.build(:activity, {:avatar => @xbox_console_user})
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
end
