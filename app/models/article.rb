class Article < ActiveRecord::Base
  belongs_to :section
  belongs_to :subsection
  has_and_belongs_to_many :authors
  has_many :revisions
  has_many :workflow_comments
  has_many :workflow_updates
  has_many :images
  belongs_to :issue
  
  serialize :titles, Array
  
  has_one :front_page_article, :dependent => :destroy
  has_one :web_published_article, :dependent => :destroy
  has_many :viewed_articles, :dependent => :destroy
  
  has_many :reviews, :class_name => "WorkflowReview"
  has_many :review_slots, :through => :reviews
  
  validates_presence_of :name
  validates_presence_of :section
  
  default_scope :order => 'created_at DESC'
  
  belongs_to :locked_by, :class_name => 'User', :foreign_key => 'locked_by'
  
  def locked?
    not locked_by.nil?
  end
  
  def lock(user)
    self.locked_by = user
  end
  
  def unlock
    self.locked_by = nil
  end
  
  def davslug
    s = to_s.gsub('/', '-')
    "#{id} #{s}"
  end
  
  def has_review? (slot)
    reviews.where(:review_slot_id => slot.id).exists?
  end
  
  def review_for_slot (slot)
    reviews.where(:review_slot_id => slot.id).first
  end
  
  def published_online?
    not web_published_article.nil?
  end
  
  def published_online_at
    web_published_article.published_at
  end
  
  def open_review_slots
    ReviewSlot.find_by_sql('SELECT review_slots.* FROM review_slots EXCEPT SELECT review_slots.* FROM review_slots INNER JOIN workflow_reviews ON (workflow_reviews.review_slot_id = review_slots.id) AND (workflow_reviews.article_id = ' + id.to_s + ')')
  end
  
  def word_count
    latest_revision.word_count if revisions.any?
  end
  
  def to_s
    name
  end
  
  def latest_revision
    revisions.latest.first
  end
  
  def teaser(count=nil)
    count ? latest_revision.teaser(count) : latest_revision.teaser
  end
  
  def status
    if revisions.where(:published_online => true).exists?
      "Published"
    else
      workflow_status.to_s
    end
  end
  
  def full_section_name
    subsection ? subsection.full_name : section.name
  end
  
  def workflow_history
    (self.workflow_comments + self.workflow_updates).sort_by(&:created_at).reverse
  end
end