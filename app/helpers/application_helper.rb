module PathHelpers
  def wiki_path
    '/wiki'
  end
  
  def article_path(article)
    File.join articles_path,
      article.published_at.year.to_s,
      article.published_at.month.to_s,
      article.published_at.day.to_s,
      article.section.url,
      article.slug
  end
  
  def authors_path
    "/authors"
  end
  
  def author_path(author)
    File.join authors_path, author.slug
  end
  
  def section_path(section)
    File.join articles_path, section.url
  end
  
  def workflow_article_headline_path(article)
    workflow_article_path(article) + "/headline"
  end
end

module ApplicationHelper
  include PathHelpers
  
  def li_tag(text, options={})
    content_tag :li, text, :class => options[:class]
  end
  
  def li_tag_if (condition, *args)
    li_tag *args if condition
  end
end

class String
  def to_slug
    # http://stackoverflow.com/questions/1302022/best-way-to-generate-slugs-human-readable-ids-in-rails/1302183#1302183
    #strip the string
    ret = self.strip.downcase

    #blow away apostrophes
    ret.gsub! /['`]/,""

    # @ --> at, and & --> and
    ret.gsub! /\s*@\s*/, " at "
    ret.gsub! /\s*&\s*/, " and "

    #replace all non alphanumeric, underscore or periods with hyphen
     ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '-'  

     #convert double hyphens to single
     ret.gsub! /-+/,"-"

     #strip off leading/trailing hyphen
     ret.gsub! /\A[_\.]+|[_\.]+\z/,""

     ret
  end
end