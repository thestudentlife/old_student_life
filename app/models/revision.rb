class Revision < ActiveRecord::Base
  belongs_to :article
  belongs_to :author, :class_name => "StaffMember"
  validates_presence_of :body
  
  def self.latest_published
    self.group("article_id"
    ).where(:published_online => true
    ).where("published_online_at < ?", Time.now
    )
  end
  
  def self.latest_headlines
    latest_published.joins(:article => [:headline]
    ).where("articles.headline_id"
    ).order("headlines.priority")
  end
  
  def self.latest_published_not_in_headlines
    latest_published.joins(:article
    ).where(:articles => {:headline_id => nil}
    ).order("published_online_at")
  end
  
  def diff(previous)
    return self.body unless previous
    require 'htmldiff'
    return HTMLDiff.diff(previous.body, self.body)
  end
  
  def to_s
    body
  end
end
