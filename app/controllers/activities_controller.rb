class ActivitiesController < ApplicationController
  before_filter :login_required, :only => :create

  def index
    @activities = Activity.recent.paginate(:page => params[:page], :order => "created_at DESC")
    respond_to do |format|
      format.html
      format.xml  { render :xml => @activities }
    end
  end

  def show
    @activity = Activity.find_by_id(params[:id])
    respond_to do |format|
      unless @activity
        format.html {
          redirect_to activities_path
          flash.now[:error] = "Invalid activity id"
        }
        format.xml { render :xml => {:errors => ["Activity is invalid"]}, :status => :unprocessable_entity }
      else
        format.html 
        format.xml  { render :xml => @activity }
      end
    end
  end

  def create
    @activity = Activity.new(params[:activity])
    respond_to do |format|
      if @activity.save
        flash[:notice] = 'Activity was successfully created.'
        format.html { redirect_to(@activity.avatar) }
        format.xml  { render :xml => @activity, :status => :created, :location => @activity }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end
end
