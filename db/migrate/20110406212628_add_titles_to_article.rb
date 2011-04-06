ArticleTitle = Class.new(ActiveRecord::Base)

class AddTitlesToArticle < ActiveRecord::Migration
  def self.up
    add_column :web_published_articles, :title, :string
    WebPublishedArticle.reset_column_information
    WebPublishedArticle.all.each do |web|
      web.title = ArticleTitle.find(web.title_id).text
      web.save!
    end
    remove_column :web_published_articles, :title_id
    
    add_column :articles, :titles, :string
    Article.reset_column_information
    ArticleTitle.all.each do |title|
      a = Article.find(title.article_id)
      puts a.inspect
      next if a.nil?
      a.titles ||= []
      a.titles << title.text
      a.save!
    end
    Article.all.each do |a|
      a.titles ||= []
      a.titles = a.titles.uniq
      a.save!
    end
    drop_table :article_titles
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
