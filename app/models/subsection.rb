class Subsection < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :url
  
  belongs_to :section
  has_many :articles
  
  default_scope :order => "priority"
  
  def to_s; name; end
  
  def full_name
    "#{section.name} – #{name}"
  end
end
