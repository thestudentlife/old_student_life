module ArticlesHelper
  def section_is_selected? (section)
    "selected" if request.fullpath.match /^\/articles\/#{section.url}/ or
      request.fullpath.match /^\/articles\/\d+\/\d+\/\d+\/#{section.url}/
  end
end
