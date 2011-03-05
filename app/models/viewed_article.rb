class ViewedArticle < ActiveRecord::Base
  belongs_to :article
  
  def self.latest_most_viewed
    where("created_at > ?", 1.weeks.ago
    ).order("published_online_at DESC"
    )
  end
end
