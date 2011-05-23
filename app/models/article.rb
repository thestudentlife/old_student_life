class Article < ActiveRecord::Base
  belongs_to :section
  has_and_belongs_to_many :authors
  has_many :revisions
  has_many :workflow_comments
  has_many :workflow_updates
  has_many :images
  belongs_to :issue
  
  has_one :workflow, :class_name => "WorkflowArticle", :dependent => :destroy
  has_one :front_page_article, :dependent => :destroy
  has_one :web_published_article, :dependent => :destroy
  has_many :viewed_articles, :dependent => :destroy
  
  has_many :reviews, :class_name => "WorkflowReview"
  has_many :review_slots, :through => :reviews
  
  validates_presence_of :section
  
  default_scope :order => 'created_at DESC'
  
  searchable do
    text :title do web_published_article.title if published_online? end
    text :body
    integer :author_ids, :multiple => true
    integer :section_id
    time :published_at do published_online_at if published_online? end
  end
  
  def workflow_with_guard
    self.workflow_without_guard || WorkflowArticle.new(:article => self)
  end
  alias_method_chain :workflow, :guard
  
  def davslug
    s = workflow.to_s.gsub('/', '-')
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
  
  include ActionView::Helpers::SanitizeHelper
  def word_count
    strip_tags(body).scan(/\s+/).length if body
  end
  
  def to_s
    name
  end
  
  def latest_revision
    revisions.latest.first
  end
  
  include ActionView::Helpers::TextHelper
  def teaser(length=100)
    sentences = strip_tags(self.body).scan(/.*?[\.\!\?]/)
    sum = sentences.shift
    sum = self.body if not sum
    while sum.length < length and sentences.any?
      sum = sum + ' ' + sentences.shift
    end
    while sum =~ /((Jan)|(Feb)|(Mar)|(Apr)|(Aug)|(Sep)|(Oct)|(Nov)|(Dec))\.$/ and sentences.any?
      sum = sum + ' ' + sentences.shift
    end
    # why wasn't it already stripping? hmm
    return strip_tags(sum)
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