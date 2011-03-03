class Revision < ActiveRecord::Base
  belongs_to :article
  belongs_to :author, :class_name => "StaffMember"
  validates_presence_of :body
  
  def to_s
    body
  end
end
