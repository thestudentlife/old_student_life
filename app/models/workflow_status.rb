class WorkflowStatus < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :priority
  
  has_many :articles
  
  default_scope :order => "priority"
  
  def to_s
    name
  end
end
