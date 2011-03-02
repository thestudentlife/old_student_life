class Article < ActiveRecord::Base
  belongs_to :workflow_status
  
  validates_presence_of :workflow_status
end
