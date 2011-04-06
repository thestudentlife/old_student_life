module Workflow
class Conductor
  
  include ActiveModel::Validations
  
  def add_errors(model)
    model.errors.each do |attribute, message|
      errors.add("#{model.class.name.underscore}_#{attribute}".to_sym, message)
    end if model.invalid?
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