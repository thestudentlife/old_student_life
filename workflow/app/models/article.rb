class Article < ActiveRecord::Base
  belongs_to :section
  belongs_to :subsection
  has_and_belongs_to_many :authors
  has_many :revisions
  has_many :workflow_comments
  has_many :workflow_updates
  has_many :images
  belongs_to :issue
  
  has_one :front_page_article
  
  has_many :titles, :class_name => "ArticleTitle"
  
  has_many :reviews, :class_name => "WorkflowReview"
  has_many :review_slots, :through => :reviews
  
  validates_presence_of :name
  validates_presence_of :section
  
  default_scope :order => 'created_at DESC'
  
  def published_online?
    WebPublishedArticle.where(:article_id => self.id).exists?
  end
  
  def published_online_at
    WebPublishedArticle.published.find_by_article_id(id).published_at
  end
  
  def to_s
    name
  end
  
  def teaser
    WebPublishedArticle.published.find_by_article_id(id).teaser
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
    (self.workflow_comments + self.revisions + self.workflow_updates).sort_by &:created_at
  end
  
  def workflow_history_visible_to_article_author
    (self.workflow_comments.where(:visible_to_article_author => true) + \
     self.revisions.where(:visible_to_article_author => true)).sort_by &:created_at
  end
end
