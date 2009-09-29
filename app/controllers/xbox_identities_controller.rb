class XboxIdentitiesController < ApplicationController
  before_filter :login_required, :only => [:new, :create]
  before_filter :load_page_title, :only => [:new, :create]

  def index
    @page_title = "Xbox360 gamertags"
    @xbox_identities = XboxIdentity.paginate(:page => params[:page], :order => "created_at DESC")
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @xbox_identities }
    end
  end

  def show
    @xbox_identity = XboxIdentity.find_by_id(params[:id])
    respond_to do |format|
      unless @xbox_identity
        format.html { 
          redirect_to(xbox_identities_path)
          flash[:error] = "Invalid xbox360 gamertag"
        }
        format.xml  { render :xml => {:errors => ["Xbox360 user id is invalid"]}, :status => :unprocessable_entity }
      else
        format.html { 
          @page_title = "Viewing details for #{@xbox_identity.name}" 
          @activities = @xbox_identity.activities.recent.paginate(:page => params[:page], :order => "created_at DESC")
        } 
        format.xml  { render :xml => @xbox_identity }
      end
    end
  end

  def new
    @xbox_identity = XboxIdentity.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @xbox_identity }
    end
  end

  def create
    @xbox_identity = XboxIdentity.new(params[:xbox_identity].merge(:user_id => current_user.id))
    respond_to do |format|
      if @xbox_identity.save
        format.html { redirect_to(@xbox_identity) }
        format.xml  { render :xml => @xbox_identity, :status => :created, :location => @xbox_identity }
        flash.now[:notice] = 'Xbox360 account was successfully added'
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @xbox_identity.errors, :status => :unprocessable_entity }
      end
    end
  end

  def list
    @user = User.find_by_login(params[:login])
    if @user
      @page_title = "#{@user.login}'s Xbox360 avatars"
      @xbox_identities = @user.xbox_identities
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
