class WorkflowController < ApplicationController
  before_filter :authenticate_user!
  responders :flash
  layout 'workflow'
  
  rescue_from User::NotAuthorized, :with => :not_authorized
  
  private
  
  def not_authorized
    flash[:error] = "You do not have the correct permissions to access #{request.fullpath}"
    redirect_to workflow_path
  end
end
