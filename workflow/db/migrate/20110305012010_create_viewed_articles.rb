class CreateViewedArticles < ActiveRecord::Migration
  def self.up
    create_table :viewed_articles do |t|
      t.belongs_to :article, :null => false
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :viewed_articles
  end
end
