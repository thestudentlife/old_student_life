class Revision < ActiveRecord::Base
  belongs_to :article
  belongs_to :author, :class_name => "User"
  validates_presence_of :body
  
  def published_online?
    WebPublishedArticle.where(:revision_id => id).exists?
  end
  
  def published_online_at
    WebPublishedArticle.where(:revision_id => id).group(:revision_id).first.published_at
  end
  
  def published_in_print?
    PrintPublishedArticle.where(:revision_id => id).exists?
  end
  
  def previous
    Revision.where(:article_id => article.id).where("created_at < ?", created_at).order("created_at").first
  end
  
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper
  def teaser(length=100)
    sentences = strip_tags(body).scan(/.*?[\.\!\?]/)
    sum = sentences.shift
    sum = body if not sum
    while sum.length < length and sentences.first
      sum = sum + sentences.shift
    end
    while sum =~ /((Jan)|(Feb)|(Mar)|(Apr)|(Aug)|(Sep)|(Oct)|(Nov)|(Dec))\.$/ and sentences.first
      sum = sum + sentences.shift
    end
    # why wasn't it already stripping? hmm
    return strip_tags(sum)
  end
  
  def diff
    return self.body unless previous
    require 'htmldiff'
    return HTMLDiff.diff(previous.body, self.body)
  end
  
  def to_s
    body
  end
end
