class ArticleTitle < ActiveRecord::Base
  belongs_to :article
  belongs_to :author, :class_name => 'User'
  
  def to_s
    text
  end
end
