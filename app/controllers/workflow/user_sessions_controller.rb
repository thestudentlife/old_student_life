class Workflow::UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default workflow_path
    else
      render :action => :new
    end
  end
  
  def destroy
    if current_user
      current_user_session.destroy
      flash[:notice] = "Logout successful!"
      redirect_to workflow_login_path, :notice => "Logout successful!"
    else
      redirect_to workflow_login_path
    end
  end
  
  private
  def require_no_user
    if current_user
      flash[:notice] = "You are already logged in!"
      redirect_to workflow_path
      return false
    end
  end
end