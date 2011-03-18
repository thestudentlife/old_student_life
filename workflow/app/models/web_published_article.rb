class WebPublishedArticle < ActiveRecord::Base
  belongs_to :article
  belongs_to :revision
  belongs_to :title, :class_name => 'ArticleTitle'
  
  has_many :authors, :through => :article
  has_one :section, :through => :article
  has_one :subsection, :through => :article
  
  def self.published
    group("article_id").where("published_at < ?", Time.now)
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
    ).joins('INNER JOIN "articles_authors" ON "articles_authors"."article_id" = "articles"."id"'
    ).joins('INNER JOIN "authors" ON "authors"."id" = "articles_authors"."author_id"'
    ).where(:authors => {:id => author.id })
  end
end