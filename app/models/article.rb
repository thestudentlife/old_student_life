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
    review_for_slot(slot) ? true : false
  end
  
  def review_for_slot (slot)
    reviews.to_a.find { |r| r.review_slot_id == slot.id }
  end
  
  def published_online?
    not web_published_article.nil?
  end
  
  def published_online_at
    web_published_article.published_at
  end
  
  def open_review_slots
    ReviewSlot.all - ReviewSlot.joins("INNER JOIN workflow_reviews ON (workflow_reviews.review_slot_id = review_slots.id AND workflow_reviews.article_id = #{id})")
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

# WebDAV really needs to be converted into an Engine

Article.class_eval do
  after_save do
    Rails.cache.delete Workflow::Dav::Cache.lockfile_key(id)
  end
  before_destroy do
    Rails.cache.delete Workflow::Dav::Cache.lockfile_key(id)
  end
end