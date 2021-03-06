require File.dirname(__FILE__) + '/../spec_helper'
include UsersHelper
include ActionView::Helpers::UrlHelper
include ActionView::Helpers::TagHelper
include ActionController::Routing
include ActionController::HttpAuthentication::Basic::ControllerMethods

describe UsersHelper do
  before do
    @user = users(:jennifer)
  end
  
  describe "if_authorized" do 
    it "yields if authorized" do
      UsersHelper.expects(:authorized?).with("a", "r").once.returns(true)
      UsersHelper.if_authorized?('a','r') { |action, resource| [action,resource,'hi'] }.should == ['a','r','hi']
    end
    it "does nothing if not authorized" do
      UsersHelper.expects(:authorized?).with('a','r').returns(false)
      UsersHelper.if_authorized?('a','r'){ 'hi' }.should be_nil
    end
  end
  
  describe "link_to_user" do
    it "should give an error on a nil user" do
      lambda { link_to_user(nil) }.should raise_error('Invalid user')
    end
    it "should link to the given user" do
      UsersHelper.expects(:user_path).at_least_once.returns('/users/1')
      UsersHelper.link_to_user(@user).should have_tag("a[href='/users/1']")
    end
    it "should use given link text if :content_text is specified" do
      UsersHelper.expects(:user_path).at_least_once.returns('/users/1')
      UsersHelper.link_to_user(@user, :content_text => 'Hello there!').should have_tag("a", 'Hello there!')
    end
    it "should use the login as link text with no :content_method specified" do
      UsersHelper.expects(:user_path).at_least_once.returns('/users/1')
      UsersHelper.link_to_user(@user).should have_tag("a", "#{@user.login}")
    end
    it "should use the name as link text with :content_method => :created_at" do
      link_to_user(@user, :content_method => :created_at).should have_tag("a", "#{@user.created_at}")
    end
    it "should use the login as title with no :title_method specified" do
      link_to_user(@user).should have_tag("a[title=\"#{@user.login}\"]")
    end
    it "should use the name as link title with :content_method => :login" do
      link_to_user(@user, :title_method => :login).should have_tag("a[title=\"#{@user.login}\"]")
    end
    it "should have nickname as a class by default" do
      link_to_user(@user).should have_tag("a.username")
    end
    it "should take other classes and no longer have the nickname class" do
      result = link_to_user(@user, :class => 'foo bar')
      result.should have_tag("a.foo")
      result.should have_tag("a.bar")
    end
  end

  describe "link_to_login_with_IP" do
    it "should link to the login_path" do
      UsersHelper.expects(:login_path).once.returns("/login")
      UsersHelper.expects(:request).once.returns(ActionController::Request.new("0.0.0.0"))
      UsersHelper.link_to_login_with_IP().should have_tag("a[href='/login']")
    end
    it "should use given link text if :content_text is specified" do
      link_to_login_with_IP('Hello there!').should have_tag("a", 'Hello there!')
    end
    it "should use the login as link text with no :content_method specified" do
      link_to_login_with_IP().should have_tag("a", '0.0.0.0')
    end
    it "should use the ip address as title" do
      link_to_login_with_IP().should have_tag("a[title='0.0.0.0']")
    end
    it "should by default be like school in summer and have no class" do
      link_to_login_with_IP().should_not have_tag("a.nickname")
    end
    it "should have some class if you tell it to" do
      result = link_to_login_with_IP(nil, :class => 'foo bar')
      result.should have_tag("a.foo")
      result.should have_tag("a.bar")
    end
    it "should have some class if you tell it to" do
      result = link_to_login_with_IP(nil, :tag => 'abbr')
      result.should have_tag("abbr[title='0.0.0.0']")
    end
  end

  describe "link_to_current_user, When logged in" do
    before do
      login_as @user
    end
    it "should link to the given user" do
      link_to_current_user().should have_tag("a[href='/users/#{@user.id}']")
    end
    it "should use given link text if :content_text is specified" do
      link_to_current_user(:content_text => 'Hello there!').should have_tag("a", 'Hello there!')
    end
    it "should use the login as link text with no :content_method specified" do
      link_to_current_user().should have_tag("a", "#{@user.login}")
    end
    it "should use the name as link text with :content_method => :name" do
      link_to_current_user(:content_method => :created_at).should have_tag("a", "#{@user.created_at}")
    end
    it "should use the login as title with no :title_method specified" do
      link_to_current_user().should have_tag("a[title=\"#{@user.login}\"]")
    end
    it "should use the login as link title with :content_method => :name" do
      link_to_current_user(:title_method => :login).should have_tag("a[title=\"#{@user.login}\"]")
    end
    it "should have nickname as a class" do
      link_to_current_user().should have_tag("a.username")
    end
    it "should take other classes and no longer have the nickname class" do
      result = link_to_current_user(:class => 'foo bar')
      result.should have_tag("a.foo")
      result.should have_tag("a.bar")
    end
  end

  describe "link_to_current_user, When logged out" do
    it "should link to the login_path" do
      link_to_current_user().should have_tag("a[href='/login']")
    end
    it "should use given link text if :content_text is specified" do
      link_to_current_user(:content_text => 'Hello there!').should have_tag("a", 'Hello there!')
    end
    it "should use 'not signed in' as link text with no :content_method specified" do
      link_to_current_user().should have_tag("a", 'not signed in')
    end
    it "should use the ip address as title" do
      link_to_current_user().should have_tag("a[title='0.0.0.0']")
    end
    it "should by default be like school in summer and have no class" do
      link_to_current_user().should_not have_tag("a.nickname")
    end
    it "should have some class if you tell it to" do
      result = link_to_current_user(:class => 'foo bar')
      result.should have_tag("a.foo")
      result.should have_tag("a.bar")
    end
  end

end
