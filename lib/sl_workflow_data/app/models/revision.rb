# The body of a revision must be in a special format, to expidite
# conversion between HTML and InCopy.
#
# Basic ideas:
# At the toplevel, there exist only <p> nodes
# Inside each <p>, there exist only <span> nodes
# Inside each <span>, there exists only one text node
# <span> elements have various classes applied to them
#
# The trick here is taking raw HTML (which can look like anything)
# and converting it into this schema. However, we don't want to be
# too strict: the user shouldn't ever be penalized because their
# browser does something slightly differently.
#

require 'nokogiri'

class Revision < ActiveRecord::Base
  belongs_to :article
  belongs_to :author, :class_name => "User"
  validates_presence_of :body
  
  default_scope :order => 'created_at DESC'
  
  after_save do
    if self == self.article.latest_revision
      article.body = self.body
      article.save!
    end
  end
  
  include ActionView::Helpers::SanitizeHelper
  def word_count
    strip_tags(body).scan(/\s+/).length
  end
  
  def self.latest
    order('created_at DESC')
  end
  
  def previous
    Revision.where(:article_id => article.id).where("created_at < ?", created_at).order("created_at DESC").first
  end
  
  def diff
    return self.body unless previous
    require 'htmldiff'
    return HTMLDiff.diff(previous.body, self.body)
  end
  
  def id_pretty
    "Revision id.#{id}"
  end
  
  def to_s
    body
  end
end
