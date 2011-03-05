module WorkflowHelper
  def is_selected? (section_name)
    "selected" if request.request_uri.match /^\/workflow\/#{section_name}/
  end
end
