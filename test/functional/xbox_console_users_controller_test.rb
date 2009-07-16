require File.dirname(i__FILE__) + '/../test_helper'

class XboxConsoleUsersControllerTest < ActionController::TestCase
  def setup
    @user               = Factory(:user)
    @xbox_console_user  = Factory.build(:xbox_console_user)
  end

  def test_should_get_index
    get :index
    assert_template :index
    assert_not_nil assigns(:xbox_console_users)
  end

  def test_should_get_new
    login_as @user
    get :new, params
    assert_template :new
  end

  def test_new_without_authentication
    get :new
    assert_equal "You must be logged in to add a new Xbox360 account.", flash[:notice]
    assert_redirected_to :controller => :users, :action => :index
  end

  def test_should_create_xbox_console_user do
    login_as @user
    assert_difference ["@user.xbox_console_users", "XboxConsoleUser.count"] do
      params = {
        :xbox_console_user => {
          :gamertag => @xbox_console_user.gamertag
        }
      }
      post :create, params
      assert_redirected_to xbox_console_user_path(assigns(:xbox_console_user))
    end
  end

  def test_should_show_xbox_console_user
    params = {
      :id => @xbox_console_user.id
    } 
    get :show
    assert_response :success
  end

  def test_should_get_edit
    params = {
      :id => @user.id
    }
    get :edit, :id => xbox_console_users(:one).to_param
    assert_response :success
  end

  test "should update xbox_console_user" do
    put :update, :id => xbox_console_users(:one).to_param, :xbox_console_user => { }
    assert_redirected_to xbox_console_user_path(assigns(:xbox_console_user))
  end

  test "should destroy xbox_console_user" do
    assert_difference('XboxConsoleUser.count', -1) do
      delete :destroy, :id => xbox_console_users(:one).to_param
    end

    assert_redirected_to xbox_console_users_path
  end
end
