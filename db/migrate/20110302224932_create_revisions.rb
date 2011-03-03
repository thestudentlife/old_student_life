class CreateRevisions < ActiveRecord::Migration
  def self.up
    create_table :revisions do |t|
      t.belongs_to :article, :null => false
      t.belongs_to :author, :null => false
      t.boolean :visible_to_article_author, :default => true

      t.string :title
      t.text :body

      t.boolean :published_online, :default => false
      t.boolean :published_online_at, :null => true

      t.boolean :published_in_print, :default => false
      t.boolean :published_in_print_at, :null => true

      t.timestamps
    end
  end

  def self.down
    drop_table :revisions
  end
end