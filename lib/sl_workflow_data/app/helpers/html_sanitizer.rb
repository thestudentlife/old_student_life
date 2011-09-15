class HtmlSanitizer
	def initialize(s)
		@s = s
	end
	def sanitize
		pipe(@s,
			:fix_comment_starts,
			:convert_brs,
			:remove_tags,
			:remove_attributes,
			:convert_nbsps,
			:collapse_spaces,
			:fix_paragraphs)
	end
	def allowed_tags
		%w{p i b em strong a}
	end
	protected
	def pipe(s, *methods)
		methods.inject(s) do |t, v|
			send(v, t)
		end
	end
	def fix_comment_starts(s)
		s.gsub("<!", "<commentbang")
	end
	def convert_brs(s)
		s.gsub(/<br\s*\/?>/i, "<p>")
	end
	def remove_tags(s)
		s.gsub(/<\/?([A-Za-z0-9\:-]+).*?>/) do
			allowed_tags.include?($1.downcase) ? $& : ""
		end
	end
	def remove_attributes(s)
		s.gsub(/<(\w[\w\d\:-]*).*?>/) { "<#$1>" }
	end
	def convert_nbsps(s)
		s.gsub("&nbsp;", ' ')
	end
	def collapse_spaces(s)
		s.gsub(/\s+/, " ")
	end
	
	def tokenize_html(s)
		s.scan(/(<.*?>)|([^<]+)/).map{|tag, text| [tag ? tag.downcase : nil, text] }.flatten.reject(&:nil?)
	end
	def fix_paragraphs(s)
		tokens = tokenize_html(s)
		
		fixed = []
		
		inside_p = false
		while tokens.any?
			if not inside_p and tokens.first == "<p>"
				fixed << tokens.shift
				inside_p = true
			elsif inside_p and tokens.first == "<p>"
				fixed << "</p>"
				fixed << tokens.shift
				inside_p = true
			elsif not inside_p and tokens.first == "</p>"
				# weirddd
			elsif inside_p and tokens.first == "</p>"
				fixed << tokens.shift
				inside_p = false
			elsif not inside_p and tokens.first != "<p>"
				fixed << "<p>"
				fixed << tokens.shift
				inside_p = true
			elsif inside_p and tokens.first != "<p>" and tokens.first != "</p>"
				fixed << tokens.shift
			else
				raise Error
			end
		end
		if inside_p
			fixed << "</p>"
		end
		
		fixed.join("").gsub(/<p>\s*<\/p>/, "")
	end
end