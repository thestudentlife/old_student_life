class FrontPageArticle < ActiveRecord::Base
  belongs_to :article
  validates :priority, :numericality => { :only_integer => true }
  
  default_scope :order => 'priority ASC'
  
  def to_s
    article.title.to_s
  end
end
