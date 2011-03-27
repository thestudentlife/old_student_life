class BlogsController < ApplicationController
  
  layout "front"
  
  before_filter do @most_viewed = WebPublishedArticle.latest_most_viewed(10) end
  before_filter do @sections = Section.all end
  
  def index
  end
end
