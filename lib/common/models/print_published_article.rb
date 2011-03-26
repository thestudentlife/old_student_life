class PrintPublishedArticle < ActiveRecord::Base
  belongs_to :article
  belongs_to :revision
  belongs_to :title, :class_name => 'ArticleTitle'
  
  def self.per_article
    group("article_id")
  end
end