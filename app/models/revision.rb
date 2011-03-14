class Revision < ActiveRecord::Base
  belongs_to :article
  belongs_to :author, :class_name => "User"
  validates_presence_of :body
  
  def self.latest_published
    self.group("article_id"
    ).where(:published_online => true
    ).where("published_online_at < ?", Time.now
    )
  end
  
  def self.latest_headlines
    latest_published.joins(:article => [:headline]
    ).where("articles.headline_id"
    ).order("headlines.priority")
  end
  
  def self.latest_published_not_in_headlines
    latest_published.joins(:article
    ).where(:articles => {:headline_id => nil}
    ).order("published_online_at DESC")
  end
  
  def self.latest_published_for_article (article_id)
    latest_published.where(:article_id => article_id).first
  end
  
  def previous
    Revision.where(:article_id => article.id).where("created_at < ?", created_at).order("created_at").first
  end
  
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper
  def summary(length=100)
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
  
  def long_summary
    summary 300
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
