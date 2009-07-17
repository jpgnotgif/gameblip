require File.dirname(__FILE__) + '/../test_helper'

class XboxConsoleUsersControllerTest < ActionController::TestCase
  def setup
    @user               = users(:josephpgutierrez)
    @xbox_console_user  = Factory.build(:xbox_console_user, {:user => @user})
    @xml                = File.open(File.join(RAILS_ROOT, "test/files/xml/xbox_live", "foo.xml"), "r") { |f| f.read }
  end

  def test_should_get_index
    get :index
    assert_template :index
    assert_not_nil assigns(:xbox_console_users)
  end

  def test_should_get_new
    login_as @user
    get :new
    assert_template :new
  end

  def test_new_without_authentication
    get :new
    assert_equal "You must be logged in to perform that action", flash[:notice]
    assert_redirected_to new_session_path 
  end

  def test_should_create_xbox_console_user
    login_as @user
    params = {
      :xbox_console_user => {
        :gamertag => @xbox_console_user.gamertag
      }
    }
    assert_difference ["@user.xbox_console_users.count", "XboxConsoleUser.count"] do
      Net::HTTP.expects(:get).with(URI.parse(AppConfig.xbox_api.url + @xbox_console_user.gamertag)).returns(@xml)
      post :create, params
      assert_not_nil assigns(:xbox_console_user)
      assert_equal "Xbox360 account was successfully added", flash[:notice]
      assert_redirected_to xbox_console_user_path(assigns(:xbox_console_user))
    end
  end

  def test_should_show_xbox_console_user
    assert_difference ["@user.xbox_console_users.count", "XboxConsoleUser.count"] do
      assert @xbox_console_user.save
    end
    params = {
      :id => @xbox_console_user.id
    } 
    get :show, params
    assert_template :show
  end
end