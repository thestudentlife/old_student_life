class PagesController < HighVoltage::PagesController
  layout "front"
  
  before_filter do @most_viewed = ViewedArticle.latest_most_viewed(10) end
  before_filter do @sections = Section.all end
end