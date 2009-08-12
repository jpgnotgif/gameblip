class PlaystationConsoleUsersController < ApplicationController
  before_filter :login_required, :only => [:new, :create]
  before_filter :load_page_title

  def index
    @page_title = "PSN IDs"
    @playstation_console_users = PlaystationConsoleUser.paginate(:page => params[:page], :order => "created_at DESC")
    respond_to do |format|
      format.html
      format.xml { render :xml => @playstation_console_users }
    end
  end

  def new
    @playstation_console_user = PlaystationConsoleUser.new
    respond_to do |format|
      format.html
      format.xml { render :xml => @playstation_console_user }
    end
  end

  def create
    @playstation_console_user = PlaystationConsoleUser.new(params[:playstation_console_user].merge(:user_id => current_user.id))
    respond_to do |format|
      if @playstation_console_user.save
        format.html { redirect_to @playstation_console_user }
        format.xml { render :xml => @playstation_console_user, :status => :created, :location => @playstation_console_user }
        flash.now[:notice] = "Successfully added PSN ID"
      else
        format.html { render :action => :new }
        format.xml { render :xml => @playstation_console_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @playstation_console_user = PlaystationConsoleUser.find_by_id(params[:id])
    unless @playstation_console_user
      redirect_to playstation_console_users_path
      flash.now[:error] = "Invalid PSN user id"
    end
  end

  protected
  def load_page_title
    @page_title = "Add a new PSN ID"
  end
end
