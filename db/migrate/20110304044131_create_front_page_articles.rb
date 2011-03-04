class CreateFrontPageArticles < ActiveRecord::Migration
  def self.up
    create_table :front_page_articles do |t|
      t.integer :priority, :unique => true

      t.timestamps
    end
  end

  def self.down
    drop_table :front_page_articles
  end
end
