require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  before :each do
    @user = users(:josephpgutierrez)
    @controller.instance_eval { flash.extend(DisableFlashSweeping) } 
  end

  it "should login and redirect to show details" do
    create_session(:login => @user.login, :password => @user.login)
    session[:user_id].should_not be_nil
    response.should redirect_to(user_path(@user.id))
    flash.now[:notice].should == "Logged in successfully"
  end

  it "should login with cookie and redirect to show details" do
    @user.remember_me
    @request.cookies["auth_token"] = cookie_for(@user)
    get :new
    @controller.send(:logged_in?).should be_true
  end

  it "should disallow login because of failed authentication" do
    create_session(:login => @user.login, :password => "bad_password")
    session[:user_id].should be_nil
    flash.now[:error].should == "Invalid username or password"
    response.should render_template(:new)
  end

  it "should logout user" do
    login_as @user
    get :destroy
    session[:user_id].should be_nil
    response.should redirect_to(login_path)
  end

  it "should remember me" do
    create_session(:login => @user.login, :password => @user.login, :remember_me => "1")
    @response.cookies["auth_token"].should_not be_nil
    session[:user_id].should_not be_nil
    response.should redirect_to(user_path(@user.id))
    flash.now[:notice].should == "Logged in successfully"
  end

  it "should not remember me" do
    create_session(:login => @user.login, :password => @user.login, :remember_me => "0")
    @response.cookies["auth_token"].should be_nil
    session[:user_id].should_not be_nil
    response.should redirect_to(user_path(@user.id))
    flash.now[:notice].should == "Logged in successfully"
  end

  it "should delete the token on logout" do
    login_as @user
    get :destroy
    @response.cookies["auth_token"].should be_nil
  end

  it "should disallow login because of expired cookie" do
    @user.remember_me
    @user.update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(@user)
    get :new
    @controller.send(:logged_in?).should be_false
  end

  it "should disallow login because of invalid cookie" do
    @user.remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    @controller.send(:logged_in?).should be_false
  end

  protected
  def create_session(options = {})
    post :create, params.merge(options)
  end

  def auth_token(token)
     CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
   
  def cookie_for(user)
    if user.is_a?(User)
      auth_token user.remember_token
    else
      auth_token users(user).remember_token
    end
  end
end
