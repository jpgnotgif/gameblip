require File.dirname(__FILE__) + '/../spec_helper'

describe PlaystationConsoleUsersController do
  before do
    @user = users(:brian)
    @playstation_console_user = Factory.build(:playstation_console_user, {:user => @user})
    @url = AppConfig.instance_variable_get(:@config).psn_api.url
    @profile = AppConfig.instance_variable_get(:@config).psn_api.profile
    @profile_xml = File.open(File.join(RAILS_ROOT, "spec/files/xml/psn/geek_at_home/profile.xml")) { |f| f.read }
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
  end

  it "should map 'ps3/avatars to {:controller => 'playstation_console_users', :action => 'index'}'" do
    route_for(:controller => "playstation_console_users", :action => "index").should == "ps3/avatars"
  end

  it "should map 'ps3/avatars/list/:login' to {:controller => 'playstation_console_users', :action => 'list', :login => :user_login}" do
    route_for(:controller => "playstation_console_users", :action => "list", :login => "#{@user.login}").should == "/ps3/avatars/list/#{@user.login}"
  end

  it "should get index page" do
    get :index
    assigns(:playstation_console_users).should_not be_nil
    response.should render_template(:index)
  end

  it "should get show page" do
    Net::HTTP.expects(:get).with(URI.parse(@url + @playstation_console_user.psn_id + @profile)).returns(@profile_xml)
    u = Factory(:playstation_console_user, {:user => @user})
    params = {
      :id => u.id
    }   
    get :show, params
    assigns(:playstation_console_user).should be_an_instance_of(PlaystationConsoleUser)
    response.should render_template(:show)
  end
  
  it "should require valid id on show page" do
    params = {
      :id => nil
    }
    get :show, params
    assigns(:playstation_console_user).should be_nil
    flash.now[:error].should == "Invalid PSN user id"
    response.should redirect_to(playstation_console_users_path)
  end

  it "should get new page" do
    login_as @user
    get :new
    assigns(:playstation_console_user).should be_instance_of(PlaystationConsoleUser)
    response.should render_template(:new)
  end

  it "should require authentication on new page" do
    get :new
    assigns(:playstation_console_user).should be_nil
    response.should redirect_to(login_path) 
  end

  it "should create" do
    Net::HTTP.expects(:get).with(URI.parse(@url + @playstation_console_user.psn_id + @profile)).returns(@profile_xml)
    login_as @user
    lambda {
      params = {
        :playstation_console_user => {
          :psn_id => @playstation_console_user.psn_id
        }
      }
      create_playstation_console_user(params)
      @user.playstation_console_users.count.should == 1
      flash.now[:notice].should == "Successfully added PSN ID"
      assigns(:playstation_console_user).should be_instance_of(PlaystationConsoleUser) 
      response.should redirect_to(playstation_console_user_path(assigns(:playstation_console_user).id))
    }.should change(PlaystationConsoleUser, :count).by(1)
  end

  it "should require authentication on create" do
    lambda {
      params = {
        :playstation_console_user => {
          :psn_id => @playstation_console_user.psn_id
        }
      }
      create_playstation_console_user(params)
      @user.playstation_console_users.count.should == 0
      flash.now[:notice].should == "You must be logged in to do that"
      response.should redirect_to(login_path)   
    }.should_not change(PlaystationConsoleUser, :count).by(1)
  end 

  protected
  def create_playstation_console_user(params)
    post :create, params
  end

end
