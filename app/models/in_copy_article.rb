class InCopyArticle < ActiveRecord::Base
  belongs_to :article
  
  validates :article, :presence => true
  
  def self.for_article(article)
    where(:article_id => article.id).first || new(:article => article)
  end
end
