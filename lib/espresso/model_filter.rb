module Espresso
  class ModelFilter
    class_attribute :model, :filter_classes
    def self.filter(name, opts={})
      self.filter_classes ||= []
      self.filter_classes.push(("Espresso::" + name.to_s.camelize + "Filter").constantize.factory(opts))
    end
    
    attr_accessor :collection, :filters
    def initialize(params, initial_collection=Article.scoped)
      @filters = filter_classes.map { |k| k.new(params) }
      @filters.push SortFilter.new params
      @collection = @filters.inject(initial_collection) do |c, f|
        f.call(c) || c
      end
    end
    def opts(params={})
      @filters.map(&:opts).inject(&:merge).merge(params)
    end
  end
end