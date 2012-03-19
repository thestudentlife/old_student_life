module Espresso
  class SortFilter
    attr_accessor :opts
    def initialize(params)
      self.opts = {}
      self.opts[:sort] = if params[:sort].present?
        params[:sort].gsub(":", " ")
      end
    end
    def call(query)
      query.order(opts[:sort]) if opts[:sort]
    end
    def type
      "hidden"
    end
  end
end