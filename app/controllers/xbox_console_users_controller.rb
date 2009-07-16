class XboxConsoleUsersController < ApplicationController
  def index
    @xbox_console_users = XboxConsoleUser.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @xbox_console_users }
    end
  end

  def show
    @xbox_console_user = XboxConsoleUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @xbox_console_user }
    end
  end

  # GET /xbox_console_users/new
  # GET /xbox_console_users/new.xml
  def new
    @xbox_console_user = XboxConsoleUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @xbox_console_user }
    end
  end

  # GET /xbox_console_users/1/edit
  def edit
    @xbox_console_user = XboxConsoleUser.find(params[:id])
  end

  # POST /xbox_console_users
  # POST /xbox_console_users.xml
  def create
    @xbox_console_user = XboxConsoleUser.new(params[:xbox_console_user])

    respond_to do |format|
      if @xbox_console_user.save
        flash[:notice] = 'XboxConsoleUser was successfully created.'
        format.html { redirect_to(@xbox_console_user) }
        format.xml  { render :xml => @xbox_console_user, :status => :created, :location => @xbox_console_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @xbox_console_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /xbox_console_users/1
  # PUT /xbox_console_users/1.xml
  def update
    @xbox_console_user = XboxConsoleUser.find(params[:id])

    respond_to do |format|
      if @xbox_console_user.update_attributes(params[:xbox_console_user])
        flash[:notice] = 'XboxConsoleUser was successfully updated.'
        format.html { redirect_to(@xbox_console_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @xbox_console_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /xbox_console_users/1
  # DELETE /xbox_console_users/1.xml
  def destroy
    @xbox_console_user = XboxConsoleUser.find(params[:id])
    @xbox_console_user.destroy

    respond_to do |format|
      format.html { redirect_to(xbox_console_users_url) }
      format.xml  { head :ok }
    end
  end
end
