require File.dirname(__FILE__) + '/../spec_helper'

describe ActivitiesController do
  before do
    @xml = File.open(File.join(RAILS_ROOT, "spec/files/xml/xbox_live", "jpgnotgif.xml"), "r") { |f| f.read }
    @url = AppConfig.instance_variable_get(:@config).xbox_api.url
    @user = users(:josephpgutierrez)
    @xbox_console_user = Factory.build(:xbox_console_user, {:user => @user})

    Net::HTTP.expects(:get).with(URI.parse(@url + @xbox_console_user.gamertag)).returns(@xml)
    @xbox_console_user.save

    @activity_attributes = Factory.attributes_for(:activity, {:avatar_id => @xbox_console_user.id, :avatar_type => @xbox_console_user.class.name, :description => "Playing Call of Duty 4"})
    @activity = Factory(:activity, {:avatar => @xbox_console_user})
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
  end

  it "should get index page" do
    get :index
    assigns(:activities).should_not be_nil
    response.should render_template("index")
  end

  it "should create new activity for avatar" do
    login_as @user
    lambda {
      params = {
        :activity => @activity_attributes
      }
      post :create, params
      assigns(:activity).should_not be_nil
      response.should redirect_to(xbox_console_user_path(@xbox_console_user.id))
      flash[:notice].should == "Thanks for updating your status!"
    }.should change(Activity, :count).by(1)
  end

  it "should not create activity with invalid description" do
    login_as @user
    avatar = eval(@activity_attributes[:avatar_type]).find_by_id(@activity_attributes[:avatar_id])
    params = {
      :activity => @activity_attributes.merge(:description => "")
    }
    post :create, params
    response.should redirect_to(eval("#{avatar.class.name.underscore}_path(#{avatar.id})"))
    flash[:notice].should be_nil
    flash[:error].should == "Invalid activity description"
  end

  it "should require authentication on create" do
    lambda {
      params = {
        :activity => @activity_attributes
      }
      post :create, params
      assigns(:activity).should be_nil
      eval(@activity_attributes[:avatar_type]).find_by_id(@activity_attributes[:avatar_id]).activities.count.should == 1
      response.should redirect_to(login_path)
    }.should_not change(Activity, :count).by(1)
  end

  it "should show activity" do
    params = {
      :id => @activity.id
    }
    get :show, params
    assigns(:activity).should(be_instance_of(Activity))
    response.should render_template("show")
  end

  it "should require valid activity id on show" do
    params = {
      :id => nil
    }
    get :show, params
    assigns(:activity).should be_nil
    response.should redirect_to(activities_path)
    flash.now[:error].should == "Invalid activity id"
  end
end
