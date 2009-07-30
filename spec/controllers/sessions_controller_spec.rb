require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  before :each do
    @user = users(:josephpgutierrez)
  end

  it "should login and redirect to show details" do
    create_session(:login => @user.login, :password => @user.login)
    session[:user_id].should_not be_nil
    response.should redirect_to(user_path(@user.id))
    flash[:notice].should == "Logged in successfully"
  end

  it "should login with cookie and redirect to show details" do

  end

  it "should disallow login because of failed authentication" do

  end

  it "should logout user" do

  end

  it "should remember me" do

  end

  it "should not remember me" do

  end

  it "should delete the token on logout" do

  end

  it "should disallow login because of expired cookie" do

  end

  it "should disallow login because of invalid cookie" do

  end

  protected
  def create_session(options = {})
    post :create, params.merge(options)
  end
  
end
