class WorkflowComment < ActiveRecord::Base
  belongs_to :article
  belongs_to :author, :class_name => "User"
  validates_presence_of :text
  
  def to_s
    text
  end
end
