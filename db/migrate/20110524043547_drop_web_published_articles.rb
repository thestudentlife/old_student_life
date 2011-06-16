class Article < ActiveRecord::Base
  has_one :web_published_article
end

class WebPublishedArticle < ActiveRecord::Base
  belongs_to :article
end

class DropWebPublishedArticles < ActiveRecord::Migration
  def self.up
    WebPublishedArticle.all.each do |w|
      w.article.published = true
      w.article.published_at = w.published_at
      w.article.title = w.title
      puts "#{w.article.id}: #{w.article.title} #{w.article.published_at}"
      w.article.save!
    end
    
    drop_table :web_published_articles
  end
end
