class Article < ActiveRecord::Base
  belongs_to :workflow_status
  belongs_to :section
  has_many :workflow_comments
  
  validates_presence_of :workflow_status, :section
end
