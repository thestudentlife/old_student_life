module ApplicationHelper
  def li_tag(text, options={})
    content_tag :li, text, :class => options[:class]
  end
end
