class XboxConsoleUsersController < ApplicationController
  before_filter :login_required, :only => [:new, :create]
  before_filter :load_page_title, :only => [:new, :create]

  def index
    @page_title = "Xbox360 gamertags"
    @xbox_console_users = XboxConsoleUser.paginate(:page => params[:page], :order => "created_at DESC")
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @xbox_console_users }
    end
  end

  def show
    @xbox_console_user = XboxConsoleUser.find_by_id(params[:id])
    respond_to do |format|
      unless @xbox_console_user
        format.html { render :action => :index }
        format.xml  { render :xml => {:errors => ["Xbox360 user id is invalid"]}, :status => :unprocessable_entity }
      else
        format.html { 
          @page_title = "Viewing details for #{@xbox_console_user.gamertag}" 
          @activities = @xbox_console_user.activities.recent.paginate(:page => 1, :order => "created_at DESC", :per_page => 4)
        } 
        format.xml  { render :xml => @xbox_console_user }
      end
    end
  end

  def new
    @xbox_console_user = XboxConsoleUser.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @xbox_console_user }
    end
  end

  def create
    @xbox_console_user = XboxConsoleUser.new(params[:xbox_console_user].merge(:user_id => current_user.id))
    respond_to do |format|
      if @xbox_console_user.save
        format.html { redirect_to(@xbox_console_user) }
        format.xml  { render :xml => @xbox_console_user, :status => :created, :location => @xbox_console_user }
        flash.now[:notice] = 'Xbox360 account was successfully added'
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @xbox_console_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def list
    @user = User.find_by_login(params[:login])
    if @user
      @page_title = "#{@user.login}'s Xbox360 avatars"
      @xbox_console_users = @user.xbox_console_users
    else
      redirect_to users_path
      flash.now[:error] = "Invalid user id"
    end
  end

  protected
  def load_page_title
    @page_title = "Add a new Xbox360 gamertag"
  end
end
