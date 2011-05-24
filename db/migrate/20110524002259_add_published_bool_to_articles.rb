class AddPublishedBoolToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :published, :boolean
    add_column :articles, :published_at, :datetime
    add_column :articles, :title, :string
    
    Article.reset_column_information
    
    WebPublishedArticle.all.each do |w|
      w.article.published = true
      w.article.published_at = w.published_at
      w.article.title = w.title
      puts "#{w.article.id}: #{w.article.title} #{w.article.published_at}"
      w.article.save!
    end
  end
end
