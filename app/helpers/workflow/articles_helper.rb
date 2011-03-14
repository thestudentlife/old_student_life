module Workflow::ArticlesHelper
	def render_collection_in_same_controller (collection, opts={})
	  collection.map do |item|
      slug = item.class.name.underscore
      render opts.merge(:partial => slug, :locals => {slug.to_sym => item})
    end.join("\n").html_safe
	end
end