class DropWebPublishedArticles < ActiveRecord::Migration
  def self.up
    drop_table :web_published_articles
  end
end
