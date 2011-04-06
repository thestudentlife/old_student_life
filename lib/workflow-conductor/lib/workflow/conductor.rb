module Workflow
class Conductor
  class_inheritable_accessor :conducted
  self.conducted = {}
  
  include ActiveModel::Validations
  
  def add_errors(model)
    model.errors.each do |attribute, message|
      errors.add(attribute, message)
    end if model.invalid?
  end
  
  def self.conducts(opts={})
    conducted.merge! opts
    
    opts.each do |name, model|
      model.column_names.each do |column|
        define_method("#{name}_#{column}") do
          instance_variable_get("@#{name}").send(column)
        end
      end
    end
  end
  
  def initialize(params={})
    self.class.conducted.each do |name, model|
      model_params = {}
      params.each do |key, value|
        if key.to_s =~ /^#{name}_/
          model_params[key.to_s.sub(/^#{name}_/, '')] = value
        end
      end
      instance_variable_set("@#{name}", model.new(model_params))
      m = Module.new do
        define_method(name) { instance_variable_get("@#{name}") }
      end
      self.extend m
    end
  end
  
  def self.human_attribute_name(attr, options={})
    attr.to_s.humanize
  end
  
  def transact(&b)
    begin
      ActiveRecord::Base.transaction(&b)
    rescue
      false
    end
    true
  end
  
  def self.model_name
    @_model_name ||= ActiveModel::Name.new(self)
  end
end # class Conductor
end # module Workflow