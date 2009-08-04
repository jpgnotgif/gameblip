require File.dirname(__FILE__) + '/../spec_helper'

describe XboxConsoleUsersController do
  before do
    @user               = users(:josephpgutierrez)
    @xbox_console_user  = Factory.build(:xbox_console_user, {:user => @user})
    @xml                = File.open(File.join(RAILS_ROOT, "test/files/xml/xbox_live", "jpgnotgif.xml"), "r") { |f| f.read }
  end 

  it "should get index page" do
    get :index
    response.should render_template(:index)
    assigns(:xbox_console_users).should_not be_nil
  end

  it "should get new page" do
    login_as @user
    get :new
    response.should render_template(:new)
  end

  it "should authenticate before new page" do
    get :new
    flash[:notice].should == "You must be logged in to do that"
    response.should redirect_to(login_path)
  end

  it "should create xbox console user" do
    login_as @user
    lambda {
      lambda {
        create_xbox_console_user
        assigns(:xbox_console_user).should be_instance_of(XboxConsoleUser)
        flash[:notice].should == "Xbox360 account was successfully added"
      }.should change(@user.xbox_console_users, :count).by(1)
    }.should change(XboxConsoleUser, :count).by(1)
  end

  it "should show xbox console user" do
    Net::HTTP.stubs(:get).with(URI.parse(AppConfig.xbox_api.url + @xbox_console_user.gamertag)).returns(@xml)
    Factory(:xbox_console_user, {:user => @user})
    params = {
      :id => XboxConsoleUser.first.id
    }
    get :show, params
    response.should render_template(:show) 
  end

  protected
  def create_xbox_console_user(options = {})
    params = { :xbox_console_user => {} }
    Net::HTTP.stubs(:get).with(URI.parse(AppConfig.xbox_api.url + @xbox_console_user.gamertag)).returns(@xml)
    post :create, :xbox_console_user => {:gamertag => @xbox_console_user.gamertag}.merge(options)
  end
end