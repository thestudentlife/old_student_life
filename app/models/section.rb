class Section < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :url

  has_many :articles
  has_and_belongs_to_many :editors, :class_name => "User"
  has_many :subsections

  default_scope :order => "priority"

  def latest_published_revisions
    Revision.latest_published.joins(:article
    ).where(:articles => {
        :section_id => self.id
    })
  end

  def to_s
    name
  end
end
