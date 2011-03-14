class Subsection < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :url
  
  validates :priority, :numericality => { :only_integer => true }
  
  def validate
    errors[:url] << "must not start with a number" if url =~ /^[\d]/
  end
  
  belongs_to :section
  has_many :articles
  
  default_scope :order => "priority"
  
  def to_s; name; end
  
  def full_name
    "#{section.name} – #{name}"
  end
  
  def latest_published_revisions
    Revision.latest_published.joins(:article
    ).where(:articles => {
        :subsection_id => id
    })
  end
  
end
