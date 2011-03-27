class CreateArticleTitles < ActiveRecord::Migration
  def self.up
    create_table :article_titles do |t|
      t.belongs_to :article, :null => false
      t.belongs_to :author, :null => false
      t.string :text

      t.timestamps
    end
    remove_column :articles, :working_name
    remove_column :revisions, :title
  end

  def self.down
    drop_table :article_titles
  end
end
