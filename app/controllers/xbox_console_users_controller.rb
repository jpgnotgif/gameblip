class XboxConsoleUsersController < ApplicationController
  before_filter :login_required, :only => [:new, :create]

  def index
    @xbox_console_users = XboxConsoleUser.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @xbox_console_users }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @xbox_console_user }
    end
  end

  def new
    @xbox_console_user = XboxConsoleUser.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @xbox_console_user }
    end
  end

  def create
    @xbox_console_user = XboxConsoleUser.new(params[:xbox_console_user].merge(:user_id => current_user.id))
    respond_to do |format|
      if @xbox_console_user.save
        flash[:notice] = 'Xbox360 account was successfully added'
        format.html { redirect_to(@xbox_console_user) }
        format.xml  { render :xml => @xbox_console_user, :status => :created, :location => @xbox_console_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @xbox_console_user.errors, :status => :unprocessable_entity }
      end
    end
  end
end
