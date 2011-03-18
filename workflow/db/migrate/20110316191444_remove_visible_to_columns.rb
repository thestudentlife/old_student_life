class RemoveVisibleToColumns < ActiveRecord::Migration
  def self.up
    remove_column :articles, :visible
    remove_column :articles, :open_to_author
    remove_column :articles, :publishable
    
    remove_column :workflow_comments, :visible_to_article_author
    remove_column :revisions, :visible_to_article_author
    remove_column :workflow_updates, :visible_to_article_author
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
