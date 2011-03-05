class Article < ActiveRecord::Base
  belongs_to :workflow_status
  belongs_to :section
  belongs_to :subsection
  has_and_belongs_to_many :authors, :class_name => "StaffMember"
  has_many :workflow_comments
  has_many :revisions
  has_many :images
  belongs_to :headline
  has_many :viewed_articles
  
  validates_presence_of :workflow_status, :section
  
  def latest_published_revision
    revisions.where(:published_online => true
    ).where("published_online_at < ?", Time.now
    ).order("published_online_at DESC"
    ).find(:first)
  end
  
  def workflow_history
    (self.workflow_comments + self.revisions).sort_by &:created_at
  end
  
  def workflow_history_visible_to_article_author
    (self.workflow_comments.where(:visible_to_article_author => true) + \
     self.revisions.where(:visible_to_article_author => true)).sort_by &:created_at
  end
end
