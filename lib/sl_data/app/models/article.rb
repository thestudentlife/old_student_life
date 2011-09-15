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
  
  has_many :reviews, :class_name => "WorkflowReview"
  has_many :review_slots, :through => :reviews
  
  validates_presence_of :section
  
  default_scope :order => 'created_at DESC'
  
  #searchable do
  #  text :title
  #  text :body
  #  integer :author_ids, :multiple => true
  #  integer :section_id
  #  boolean :published
  #  time :published_at
  #end
  
  
  def workflow_with_guard
    self.workflow_without_guard || WorkflowArticle.new(:article => self)
  end
  alias_method_chain :workflow, :guard
  
  def self.featured
    joins('INNER JOIN front_page_articles ON (front_page_articles.article_id = articles.id)').published.order('front_page_articles.priority ASC')
  end
  
  def self.published
    where(:published => true).
    where("published_at < ?", Time.now)
  end
  
  def self.latest_most_viewed (count)
    ViewedArticle.latest_most_viewed(count).map do |article_id|
      published.find article_id
    end
  end
  
  def self.find_all_published_in_section (section) # shouldn't this be automatic?
    published.
    where(:section_id => section.id).
    order('published_at DESC')
  end
  
  def self.find_all_by_author (author) # shouldn't this be automatic?
    published.
    joins(:authors).
    where(:authors => {:id => author.id })
  end
  
  def slug
    t = to_s.to_slug.gsub(/(^-)|(-$)/,'')
    "#{id}-#{t}"
  end
  
  def davslug
    workflow.to_s.scan(/[\w\d]+/).join("-")
  end

  def davslug_with_id
    "#{id}-#{davslug}"
  end
  
  def has_review? (slot)
    review_for_slot(slot) ? true : false
  end
  
  def review_for_slot (slot)
    reviews.to_a.find { |r| r.review_slot_id == slot.id }
  end
  
  def open_review_slots
    ReviewSlot.all - ReviewSlot.joins("INNER JOIN workflow_reviews ON (workflow_reviews.review_slot_id = review_slots.id AND workflow_reviews.article_id = #{id})")
  end
  
  include ActionView::Helpers::SanitizeHelper
  def word_count
    strip_tags(body).scan(/\s+/).length if body
  end
  
  def to_s
    title.gsub(/"(.*?)"/) { "“#{$1}”" }
  end
  
  def latest_revision
    revisions.latest.first
  end
  
  include ActionView::Helpers::TextHelper
  def teaser
		truncate(strip_tags(self.body), :length => 300, :separator => " ").html_safe
  end
  
  def status
    if revisions.where(:published_online => true).exists?
      "Published"
    else
      workflow_status.to_s
    end
  end
  
  def full_section_name
    section.name
  end
  
  def workflow_history
    (self.workflow_comments + self.workflow_updates).sort_by(&:created_at).reverse
  end
end
