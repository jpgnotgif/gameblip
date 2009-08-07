class PlaystationConsoleUsersController < ApplicationController
  before_filter :login_required, :only => [:new, :create]
  before_filter :load_page_title

  def index
    @page_title = "PSN IDs"
    @playstation_console_users = PlaystationConsoleUser.all
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
    @playstation_console_user = PlaystationConsoleUser.new(params[:playstation_console_user].merge(:user_id => current_user.id)
    respond_to do |format|
      if @playstation_console_user.save
        flash[:notice] = "Successfully added PSN ID"
        format.html { redirect_to playstation_console_user_path(@playstation_console_user.id) }
        format.xml { render :xml => @playstation_console_user, :status => :created, :location => @playstation_console_user}
      else
        format.html { render :action => :new }
        format.xml { render :xml => @playstation_console_user.errors, :status => :unprocessable_entity 
      end
    end
  end

  def show
    # TODO: Continue here
  end

  protected
  def load_page_title
    @page_title = "Add a new PSN ID"
  end
end
