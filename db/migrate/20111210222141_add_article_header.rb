class AddArticleHeader < ActiveRecord::Migration
  def self.up
    add_column :articles, :header_html, :text
  end

  def self.down
		remove_column :articles, :header_html
  end
end
