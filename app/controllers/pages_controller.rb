class PagesController < HighVoltage::PagesController
  layout "front"
  
  before_filter do @most_viewed = [] end
  before_filter do @sections = Section.all end
end
