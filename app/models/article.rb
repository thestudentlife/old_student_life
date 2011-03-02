class Article < ActiveRecord::Base
  belongs_to :workflow_status
  belongs_to :section
  
  validates_presence_of :workflow_status, :section
end
