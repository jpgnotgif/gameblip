require File.dirname(__FILE__) + '/../spec_helper'

describe XboxIdentitiesController do
  before do
    @user = users(:josephpgutierrez)
    @gamer_identity_attributes = Factory.attributes_for(:gamer_identity).merge(:user => @user)
    @xbox_identity = Factory.build(:xbox_identity, @gamer_identity_attributes)
    @xml = File.open(File.join(RAILS_ROOT, "spec/files/xml/xbox_live", "jpgnotgif.xml"), "r") { |f| f.read }
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
  end 

  it "should map 'xbox360/avatars' as {:controller => :xbox_identities, :action => :index}" do
    route_for(:controller => "xbox_identities", :action => "index").should == "/xbox360/avatars"
  end

  it "should map 'xbox360/avatars/list/:login' as {:controller => :xbox_identities, :action => :list, :login => :user_login}" do
    route_for(:controller => "xbox_identities", :action => "list", :login => "#{@user.login}").should == "/xbox360/avatars/list/#{@user.login}"
  end

  it "should get index page" do
    get :index
    response.should render_template(:index)
    assigns(:xbox_identities).should_not be_nil
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

  it "should create xbox identity" do
    login_as @user
    params = {
      :xbox_identity => {
        :name => @xbox_identity.name
      }   
    }
    create_xbox_identity(params)
    assigns(:xbox_identity).should be_instance_of(XboxIdentity)
    response.should redirect_to(xbox_identities_path + "/#{assigns(:xbox_identity).id}")
    flash.now[:notice].should == "Xbox360 account was successfully added"
    @user.identities.should have(1).record
    XboxIdentity.should have(1).record
  end

  it "should not create xbox console user" do
    login_as @user
    params = {
      :xbox_identity => {
        :gamertag => nil
      }
    }
    create_xbox_identity(params)
    assigns(:xbox_identity).should be_instance_of(XboxIdentity)
    response.should render_template(:new)
    @user.identities.should have(:no).records
    XboxIdentity.should have(:no).records
  end

  it "should show xbox console user" do
    Net::HTTP.stubs(:get).with(URI.parse(AppConfig.xbox_api.url + @xbox_identity.name)).returns(@xml)
    xbox_identity = Factory(:xbox_identity, @gamer_identity_attributes)
    params = {
      :id => xbox_identity.id
    }
    get :show, params
    assigns(:xbox_identity).should(be_instance_of(XboxIdentity))
    assigns(:activities).should_not be_nil
    response.should render_template(:show)
  end

  it "should require valid id on show page" do
    params = {
      :id => "invalid_id"
    }
    get :show, params
    assigns(:xbox_identity).should be_nil
    assigns(:activities).should be_nil
    response.should redirect_to(xbox_identities_path)
    flash[:error].should == "Invalid xbox360 gamertag"
  end

  it "should show list page" do
    params = {
      :login => @user.login
    }
    get :list, params
    assigns(:page_title).should == "#{@user.login}'s Xbox360 avatars"
    assigns(:user).should == @user
    assigns(:xbox_identities).should_not be_nil
    response.should render_template("list")
  end

  it "should require valid login for list page" do
    params = {
      :login => "invalid_login"
    }
    get :list, params
    assigns(:page_title).should be_nil
    assigns(:user).should be_nil
    assigns(:xbox_identities).should be_nil
    response.should redirect_to(users_path)
    flash.now[:error].should == "Invalid user id"
  end

  protected
  def create_xbox_identity(params)
    Net::HTTP.stubs(:get).with(URI.parse(AppConfig.xbox_api.url + @xbox_identity.name)).returns(@xml)
    post :create, params
  end
end
