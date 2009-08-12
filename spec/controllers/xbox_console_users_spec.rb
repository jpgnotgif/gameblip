require File.dirname(__FILE__) + '/../spec_helper'

describe XboxConsoleUsersController do
  before do
    @user               = users(:josephpgutierrez)
    @xbox_console_user  = Factory.build(:xbox_console_user, {:user => @user})
    @xml                = File.open(File.join(RAILS_ROOT, "spec/files/xml/xbox_live", "jpgnotgif.xml"), "r") { |f| f.read }
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
  end 

  it "should map 'xbox360/avatars' as {:controller => :xbox_console_users, :action => :index}" do
    route_for(:controller => "xbox_console_users", :action => "index").should == "/xbox360/avatars"
  end

  it "should map 'xbox360/avatars/mine' as {:controller => :xbox_console_users, :action => :mine, :id => :id}" do
    route_for(:controller => "xbox_console_users", :action => "mine", :id => "#{@user.id}").should == "/xbox360/avatars/mine/#{@user.id}"
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
        params = {
          :xbox_console_user => {
            :gamertag => @xbox_console_user.gamertag
          }   
        }
        create_xbox_console_user(params)
        assigns(:xbox_console_user).should be_instance_of(XboxConsoleUser)
        response.should redirect_to(xbox_console_user_path(assigns(:xbox_console_user).id))
        flash.now[:notice].should == "Xbox360 account was successfully added"
      }.should change(@user.xbox_console_users, :count).by(1)
    }.should change(XboxConsoleUser, :count).by(1)
  end

  it "should not create xbox console user" do
    login_as @user
    lambda {
      lambda {
        params = {
          :xbox_console_user => {
            :gamertag => nil
          }   
        }
        create_xbox_console_user(params)
        assigns(:xbox_console_user).should be_instance_of(XboxConsoleUser)
        response.should render_template(:new)
      }.should_not change(@user.xbox_console_users, :count).by(1)
    }.should_not change(XboxConsoleUser, :count).by(1)
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
  def create_xbox_console_user(params)
    Net::HTTP.stubs(:get).with(URI.parse(AppConfig.xbox_api.url + @xbox_console_user.gamertag)).returns(@xml)
    post :create, params
  end
end
