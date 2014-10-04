class PagesController < ApplicationController

  unloadable

  layout "front"
  
  before_filter do @most_viewed = [] end
  before_filter do @sections = Section.all end

  rescue_from ActionView::MissingTemplate do |exception|
    if exception.message =~ %r{Missing template pages/}
      raise ActionController::RoutingError, "No such page: #{params[:id]}"
    else
      raise exception
    end
  end

  def show
    render :template => current_page
  end

  protected

    def current_page
      "pages/#{clean_path}"
    end

    def clean_path
      path = Pathname.new "/#{params[:id]}"
      path.cleanpath.to_s[1..-1]
    end

end
