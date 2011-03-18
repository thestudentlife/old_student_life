module WorkflowHelper
  def is_selected? (section_name)
    "selected" if request.fullpath.match /^\/workflow\/#{section_name}/
  end
end
