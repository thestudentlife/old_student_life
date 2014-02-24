class HtmlSanitizer
  def initialize body
    @body = body
  end
	def sanitize
	  # From htmlentities gem
	  Sanitize.clean @body, :elements => %w(p i b em strong a u), :attributes => {'a' => %w(href)}
	end
end