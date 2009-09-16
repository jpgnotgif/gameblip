require File.dirname(__FILE__) + '/../spec_helper'

describe PlaystationConsoleUser do
  before :each do
    @user = users(:josephpgutierrez)
    @playstation_console_user = Factory.build(:playstation_console_user, {:user => @user})
    @xml = File.open(File.join(RAILS_ROOT, "spec/files/xml/psn/geek_at_home/profile.xml"), "r") { |file| file.read }
    @url = AppConfig.instance_variable_get(:@config).psn_api.url
    @profile = AppConfig.instance_variable_get(:@config).psn_api.profile
  end

  it "should save" do
    lambda {
      Net::HTTP.expects(:get).with(URI.parse(@url + @playstation_console_user.psn_id + @profile)).returns(@xml)
      @playstation_console_user.save.should be_true
      @user.playstation_console_users.count.should == 1
    }.should change(PlaystationConsoleUser, :count).by(1)
  end
  
  it "requires psn id" do
    @playstation_console_user.psn_id = nil
    lambda {
      @playstation_console_user.save.should be_false
      @playstation_console_user.errors.on(:psn_id).should be_true
    }.should_not change(PlaystationConsoleUser, :count).by(1)
  end

  it "requires valid user id" do
    @playstation_console_user.user_id = nil
    lambda {
      @playstation_console_user.save.should be_false
      @playstation_console_user.errors.on(:user_id).should be_true
      @user.playstation_console_users.count.should == 0
    }.should_not change(PlaystationConsoleUser, :count).by(1)
  end
end
