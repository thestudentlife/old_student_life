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
  
  def to_s
    body
  end
end
