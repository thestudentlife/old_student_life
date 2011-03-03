class Section < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :priority

  has_many :articles
  has_and_belongs_to_many :editors, :class_name => "StaffMember"

  default_scope :order => "priority"

  def to_s
    name
  end
end
