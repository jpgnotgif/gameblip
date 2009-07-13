require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

class SessionsControllerTest < ActionController::TestCase
  def setup
    @user = users(:spiderman)
  end

  def test_should_login_and_redirect
    post :create, :login => 'spiderman', :password => 'monkey'
    assert session[:user_id]
    assert_redirected_to :controller => :member
  end

  def test_should_fail_login_and_not_redirect
    post :create, :login => 'spiderman', :password => 'bad password'
    assert_nil session[:user_id]
    assert_template :new
  end

  def test_should_logout
    login_as :spiderman
    get :destroy
    assert_nil session[:user_id]
    assert_redirected_to "/login"
  end

  def test_should_remember_me
    @request.cookies["auth_token"] = nil
    post :create, :login => 'spiderman', :password => 'monkey', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    @request.cookies["auth_token"] = nil
    post :create, :login => 'spiderman', :password => 'monkey', :remember_me => "0"
    assert @response.cookies["auth_token"].blank?
  end
  
  def test_should_delete_token_on_logout
    login_as :spiderman
    get :destroy
    assert @response.cookies["auth_token"].blank?
  end

  def test_should_login_with_cookie
    @user.remember_me
    @request.cookies["auth_token"] = cookie_for(:spiderman)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    @user.remember_me
    @user.update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:spiderman)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    @user.remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
