require File.dirname(__FILE__) + '/../test_helper'

class MemberControllerTest < ActionController::TestCase
  def setup
    @user = users(:spiderman)
  end

  def test_index
    login_as @user
    get :index
    assert_template :index
  end

  def test_should_redirect_to_login
    get :index
    assert_redirected_to :controller => :session, :action => :new
  end

end
