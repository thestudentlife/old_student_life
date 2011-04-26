class AddBodyToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :body, :text
  end

  def self.down
    remove_column :articles, :body
  end
end
