class WebPublishedArticle < ActiveRecord::Base
  belongs_to :article
  
  has_one :section, :through => :article
  has_one :subsection, :through => :article
  
  validates :title, :presence => true
  
  validate do
    if article.latest_revision.nil?
      errors.add :article, "must have at least one revision"
    end
  end
  
  def authors
    article.authors
  end
  
  def images
    article.images
  end
  
  def body
    article.latest_revision.body
  end
  
  def to_s
    title.gsub(/"(.*?)"/) { "“#{$1}”" }
  end
  
  def slug
    t = to_s.to_slug.gsub(/(^-)|(-$)/,'')
    "#{article.id}-#{t}"
  end
  
  def teaser(count=nil)
    article.teaser(count)
  end
  
  
  def self.featured
    joins('INNER JOIN front_page_articles ON (front_page_articles.article_id = web_published_articles.article_id)').published.order('front_page_articles.priority ASC')
  end
  
  def self.published
    where("published_at < ?", Time.now)
  end
  
  def self.latest_most_viewed (count)
    ViewedArticle.latest_most_viewed(count).map do |article_id|
      published.find_by_article_id article_id
    end
  end
  
  def self.find_all_by_section (section) # shouldn't this be automatic?
    published.joins(:article).where(:articles => { :section_id => section.id })
  end
  
  def self.find_all_by_author (author) # shouldn't this be automatic?
    published.joins(:article
    ).joins('INNER JOIN articles_authors ON articles_authors.article_id = articles.id'
    ).joins('INNER JOIN authors ON authors.id = articles_authors.author_id'
    ).where(:authors => {:id => author.id })
  end
end