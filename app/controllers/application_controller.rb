class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper :all

  private
    
    def after_sign_out_path_for(resource_or_scope)
      workflow_path
    end
    
    def enforce_url(url)
      if request.fullpath != url
        redirect_to url, :status => :moved_permanently
      end
    end
end