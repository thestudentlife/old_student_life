class WorkflowStatus < ActiveRecord::Base
  validates_presence_of :name
  
  has_many :articles
  
  def to_s
    name
  end
end
