class ViewedArticle < ActiveRecord::Base
  belongs_to :article
  
  def self.latest_most_viewed(limit=10)
    where("created_at > ?", 1.weeks.ago
    ).select(:article_id
    ).map(&:article_id
    ).reduce({}) do |sum, value|
      sum[value] = 0 unless sum[value]
      sum[value] += 1
      sum
    end.map do |article_id, views|
      {:article_id => article_id,
       :views => views}
    end.sort_by do |article|
      article[:views]
    end.reverse[0..limit-1].map do |params|
      params[:article_id]
    end
  end
end
