module Espresso
  class BelongsToFilter
    class_attribute :model_name, :pretty_attribute
    def self.factory(opts={})
      Class.new(self).tap do |c|
        opts.each {|(k, v)| c.send("#{k}=", v) }
      end
    end
  
    def initialize(params)
      @parent_id = params[model_name]
    end
    def call(query)
      query.where("#{model_name.to_s}_id" => @parent_id) if @parent_id.present?
    end
    def opts
      {model_name => @parent_id}
    end
    def collection
      model_name.to_s.camelize.constantize.all
    end
  
  
    def pretty_collection
      collection.map do |i|
        OpenStruct.new(
          :item =>i,
          :value => i.id,
          :name => i.send(pretty_attribute)
        )
      end
    end
    def type
      "select"
    end
    def name
      model_name
    end
  end
end