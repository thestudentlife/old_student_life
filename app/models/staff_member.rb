class StaffMember < ActiveRecord::Base
  belongs_to :user
  
  has_and_belongs_to_many :sections
  has_and_belongs_to_many :articles
  
  def email
    user.email
  end
  def to_s
    email
  end
end
