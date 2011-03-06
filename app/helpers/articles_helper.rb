module ArticlesHelper
  def section_is_selected? (section)
    "selected" if request.fullpath.match /^\/articles\/#{section.url}/
  end
end
