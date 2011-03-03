class StaffMember < ActiveRecord::Base
  validates_uniqueness_of :user
  
  belongs_to :user
  
  has_and_belongs_to_many :sections
  has_and_belongs_to_many :articles
end
