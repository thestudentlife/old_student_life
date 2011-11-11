module VideoHelper
	def youtube_embed(video_id, opts)
		return "" if video_id.blank?
		content_tag("iframe", "", {
			:class => "youtube-player",
			:type => "text/html",
			:width => opts[:width],
			:height => opts[:height],
			:src => "http://www.youtube.com/embed/#{video_id}?rel=0",
			:frameborder => "0"
		})
	end
end