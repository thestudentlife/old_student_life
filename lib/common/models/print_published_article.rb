class PrintPublishedArticle < ActiveRecord::Base
  belongs_to :article
  belongs_to :revision
  belongs_to :title, :class_name => 'ArticleTitle'
  
  default_scope :order => 'created_at DESC'
  
  def self.per_article
    group("article_id")
  end
end