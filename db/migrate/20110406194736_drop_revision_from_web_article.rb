class DropRevisionFromWebArticle < ActiveRecord::Migration
  def self.up
    remove_column :web_published_articles, :revision_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
