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
  
  def published_online?
    WebPublishedArticle.where(:revision_id => id).exists?
  end
  
  def published_online_at
    WebPublishedArticle.where(:revision_id => id).group(:revision_id).first.published_at
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
  
  def self.clean_markup(markup)
    markup = markup.
    gsub('&nbsp;', '').
    gsub(/[\n\t\r]/,' ').
    gsub(/\s+/, ' ').
    gsub(/&(.*?);/) do 
      "%26#{$1}%3B"
    end
    markup = HTMLEntities.new.encode(markup, :hexadecimal)
    markup = markup.
    gsub('&#x3c;', '<').
    gsub('&#x3e;', '>').
    gsub('&#x22;', '"').
    gsub(/&(.*?);/) do 
      "%26#{$1}%3B"
    end
    
    html = Nokogiri::HTML::DocumentFragment.parse (markup)
    # Simply by passing it through Nokogiri, we deal with nested <p> tags
    # Explanation: <p> is a block-level element, so cannot exist inside
    # other block-level elements. Nokogiri insures this rule.
    doc = html.document
    
    ps = html.children.map do |child|
      if child.name != 'p'
        p = Nokogiri::XML::Node.new('p', doc)
        p << child
        p
      else
        child
      end
    end
    html = Nokogiri::XML::NodeSet.new(doc, ps)
    
    # F***ing C apis. Can't figure out how to do this any more easily
    html = Nokogiri::XML::NodeSet.new(doc, html.select { |p| not p.text.strip.empty? })
    
    (html/'span').each do |span|
      span.keys.each do |a|
        span.remove_attribute a unless a == 'class'
      end
    end
    
    html.each do |p|
      p.keys.each do |a|
        p.remove_attribute a
      end
      
      p.children.each do |child|
        if child.name != 'span'
          span = Nokogiri::XML::Node.new('span', doc)
          span.inner_html = child.to_html
          child.replace(span)
        end
      end
    end
    
    while (search = html / 'p > span > *').any?
      search.each do |extra|
        extra.swap extra.inner_html
      end
    end
    
    html.to_html.
    gsub(/%26(.*?)%3B/) do
      "&#{$1};"
    end
  end
end