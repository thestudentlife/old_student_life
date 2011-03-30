class RemovePrintPublishedArticles < ActiveRecord::Migration
  def self.up
    drop_table :print_published_articles
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
