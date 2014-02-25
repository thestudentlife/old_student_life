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
    rescue => e
      errors.add_to_base e.to_s
      return false
    end
    true
  end
  
  def persisted?
    false
  end
  
  def to_key
    nil
  end
  
  def self.model_name
    @_model_name ||= ActiveModel::Name.new(self)
  end
  
  def self.create (*args)
    new(*args).tap do |c|
      c.save
    end
  end
  
end # class Conductor