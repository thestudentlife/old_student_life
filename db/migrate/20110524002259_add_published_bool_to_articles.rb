class AddPublishedBoolToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :published, :boolean
    add_column :articles, :published_at, :datetime
    add_column :articles, :title, :string
    
    Article.reset_column_information
  end
end
