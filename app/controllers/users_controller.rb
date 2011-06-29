require 'blacklight/catalog'

class UsersController < ApplicationController
  
  before_filter :enforce_permissions, :only => [:show, :index, :edit, :update]
  
  def show
    
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  
  def index
    
    if params[:approved] == "false"
      @users = User.find_all_by_approved(false)
    else
      @users = User.all
    end
  end
  
  def edit
    @user = User.find_by_id(params[:id])
  end
    
    
    
  def update
   @user = User.find(params[:id])
 
   
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user,
                      :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors,
                      :status => :unprocessable_entity }
      end
    end
  end
  
  protected
  
  def enforce_permissions
    unless current_user && current_user.admin?
      redirect_to("/", :notice => "You currently do not have permissions to view this section. If this is an error, please contact the system administrator.")
    end
  end
  
end