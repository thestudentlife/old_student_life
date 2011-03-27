class CreatePublishedArticles < ActiveRecord::Migration
  def self.up
    create_table :web_published_articles do |t|
      t.datetime :published_at, :null => false
      
      t.belongs_to :article, :null => false
      t.belongs_to :revision, :null => false
      t.belongs_to :title, :null => false

      t.timestamps
    end
    create_table :print_published_articles do |t|
      t.belongs_to :article, :null => false
      t.belongs_to :revision, :null => false
      t.belongs_to :title, :null => false
      
      t.timestamps
    end
    change_table :revisions do |t|
      t.remove :published_online,
        :published_online_at,
        :published_in_print,
        :published_in_print_at
    end
  end

  def self.down
    drop_table :web_published_articles
    drop_table :print_published_articles
    
    change_table :revisions do |t|
      t.boolean :published_online, :default => false
      t.datetime :published_online_at, :null => true

      t.boolean :published_in_print, :default => false
      t.datetime :published_in_print_at, :null => true
    end
  end
end
