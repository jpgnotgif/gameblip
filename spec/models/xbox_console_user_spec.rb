require File.dirname(__FILE__) + '/../spec_helper'

describe XboxConsoleUser do
  before :each do
    @user = users(:josephpgutierrez)
    @xbox_console_user = Factory.build(:xbox_console_user, {:user => @user})
    @xml = File.open(File.join(RAILS_ROOT, "test/files/xml/xbox_live", "foo.xml"), "r") { |f| f.read }
    @url = AppConfig.instance_variable_get(:@config).xbox_api.url
  end

  it "should save" do
    lambda {
      Net::HTTP.should_receive(:get).once.with(URI.parse(@url + @xbox_console_user.gamertag)).and_return(@xml)
      @xbox_console_user.save.should be_true
      violated "#{@xbox_console_user.errors.full_messages.to_sentence}" if @xbox_console_user.new_record?
      @user.xbox_console_users.count.should == 1
    }.should change(XboxConsoleUser, :count).by(1)
  end

  it "requires gamertag" do
    lambda {
      @xbox_console_user.gamertag = nil
      @xbox_console_user.save.should be_false
      @xbox_console_user.errors.on(:gamertag).should_not be_nil
      @user.xbox_console_users.count.should == 0
    }.should_not change(XboxConsoleUser, :count).by(1)
  end

  it "requires valid user id" do
    lambda {
      Net::HTTP.should_receive(:get).once.with(URI.parse(@url + @xbox_console_user.gamertag)).and_return(@xml)
      @xbox_console_user.user_id = nil
      @xbox_console_user.save.should be_false
      @xbox_console_user.errors.on(:user_id).should_not be_nil
      @user.xbox_console_users.count.should == 0
    }.should_not change(XboxConsoleUser, :count).by(1)
  end
end
