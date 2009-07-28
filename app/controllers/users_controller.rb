class UsersController < ApplicationController
  before_filter :load_page_title, :only => [:new, :create]
  before_filter :login_required, :only => [:edit, :update]
  before_filter :load_user, :only => [:show, :edit, :update]
  before_filter :check_user, :only => [:edit, :update]

  def index
    show
  end

  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      redirect_back_or_default('/login')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    @page_title = "Activation"
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to login_path 
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def show
    @page_title = "Viewing all users"
    @users = User.all.paginate
    if @user
      @page_title = "Viewing #{@user.login}'s details"
      @xbox_console_users = @user.xbox_console_users
      render :template => "users/details"
    else
      render :action => :show
    end
  end

  def edit
  end

  def update
    if @user && @user.update_attributes(params[:user])
      redirect_to user_path(@user.id)
      flash[:notice] = "Updated user successfully"
    else
      render :action => :edit
    end
  end

  protected
  def load_user
    @user = User.find_by_id(params[:id])
  end

  def check_user
    unless @user && @user == current_user
      redirect_to users_path
      flash[:error] = "Invalid user"
      return false
    end
  end

  def load_page_title
    @page_title = "Register"
  end
  
end
