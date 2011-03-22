class PrintPublishedArticle < ActiveRecord::Base
  belongs_to :article
  belongs_to :revision
  belongs_to :title, :class_name => 'ArticleTitle'
  
  def self.published
    group("article_id").where("published_at < ?", Time.now).order('published_at DESC')
  end
end