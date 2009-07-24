require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

class UsersControllerTest < ActionController::TestCase
  def setup
    @new_user           = Factory.build(:user)
    @user               = users(:josephpgutierrez)
    @inactive_user      = users(:jennifer)
    @another_user       = users(:brian)
    @emails             = ActionMailer::Base.deliveries
    @emails.clear
  end

  def test_should_allow_signup
    assert_difference ['User.count', '@emails.count'] do
      create_user
      assert_redirected_to login_path 
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'User.count' do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_equal "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above).", flash[:error]
      assert_template :new
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_equal "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above).", flash[:error]
      assert_template :new
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_equal "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above).", flash[:error]
      assert_template :new
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_equal "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above).", flash[:error]
      assert_template :new
    end
  end
  
  def test_should_sign_up_user_with_activation_code
    create_user
    assigns(:user).reload
    assert_not_nil assigns(:user).activation_code
  end

  def test_should_activate_user
    assert_nil User.authenticate("jennifer", "test")
    get :activate, :activation_code => @inactive_user.activation_code
    assert_redirected_to login_path 
    assert_not_nil flash[:notice]
    assert_equal @inactive_user, User.authenticate("jennifer", "jennifer")
  end
  
  def test_should_not_activate_user_without_key
    get :activate
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end

  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # well played, sir
  end

  def test_show_with_id
    params = {
      :id => @user.id
    }
    get :show, params
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:xbox_console_users)
    assert_template :details
  end

  def test_show_with_no_id
    get :show
    assert_nil assigns(:user)
    assert_template :index
  end

  def test_edit
    login_as @user
    params = {
      :id => @user.id
    }
    get :edit, params
    assert_equal @user, assigns(:user)
    assert_template :edit
  end

  def test_edit_without_login
    params = {
      :id => @user.id
    }
    get :edit, params
    assert_redirected_to new_session_path
  end

  def test_edit_with_no_id
    login_as @user
    get :edit
    assert_template :show
    assert_equal "Invalid user", flash[:error]
  end

  def test_edit_with_invalid_id
    login_as @user
    params = {
      :id => @another_user.id
    }
    get :edit, params
    assert_redirected_to users_path
  end

  def test_should_update
    login_as @user
    params = {
      :id => @user.id,
      :user => {
        :email => "new_email@example.com"
      }
    }
    put :update, params
    assert_equal "Updated user successfully", flash[:notice]
    assert_redirected_to user_path(@user)
  end

  def test_update_with_invalid_id
    login_as @user
    params = {
      :id => nil,
      :user => {
        :email => "new_email@example.com"
      }
    }
    put :update, params
    assert_equal "Invalid user", flash[:error]
    assert_template :edit, :id => @user.id
  end

  def test_update_with_invalid_attributes
    login_as @user
    params = {
      :id => @user.id,
      :user => {
        :email => "invalid_email_address"
      }
    }
    put :update, params
    assert_template :edit, :id => @user.id
  end

  protected
    def create_user(options = {})
      params = {
        :user => {
          :login => @new_user.login,
          :email => @new_user.email,
          :password => @new_user.password,
          :password_confirmation => @new_user.password_confirmation
        }.merge(options)
      }
      post :create, params      
    end
end
