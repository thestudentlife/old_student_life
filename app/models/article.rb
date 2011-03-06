class Article < ActiveRecord::Base
  belongs_to :workflow_status
  belongs_to :section
  belongs_to :subsection
  has_and_belongs_to_many :authors, :class_name => "StaffMember"
  has_many :revisions
  has_many :workflow_comments
  has_many :workflow_updates
  has_many :images
  belongs_to :headline
  has_many :viewed_articles
  
  validates_presence_of :workflow_status, :section
  
  def slug
    "#{id}-#{latest_published_revision.title.to_slug}"
  end
  
  def summary
    latest_published_revision.summary
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
  
  def latest_published_revision
    revisions.where(:published_online => true
    ).where("published_online_at < ?", Time.now
    ).order("published_online_at DESC"
    ).find(:first)
  end
  
  def workflow_history
    (self.workflow_comments + self.revisions + self.workflow_updates).sort_by &:created_at
  end
  
  def workflow_history_visible_to_article_author
    (self.workflow_comments.where(:visible_to_article_author => true) + \
     self.revisions.where(:visible_to_article_author => true)).sort_by &:created_at
  end
end
