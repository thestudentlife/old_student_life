class Revision < ActiveRecord::Base
  belongs_to :article
  belongs_to :author, :class_name => "StaffMember"
  validates_presence_of :body
  
  def self.latest_published
    self.group("article_id"
    ).where(:published_online => true
    ).where("published_online_at < ?", Time.now
    ).order("published_online_at")
  end
  
  def self.latest_published_on_front_page
    latest_published.joins(:article => [:front_page_article]
    ).where("articles.front_page_article_id"
    ).order("front_page_articles.priority")
  end
  
  def self.latest_published_not_on_front_page
    latest_published.joins(:article
    ).where(:articles => {:front_page_article_id => nil})
  end
  
  def to_s
    body
  end
end
