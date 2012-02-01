class DropViewedArticles < ActiveRecord::Migration
  def self.up
		drop_table :viewed_articles
  end

  def self.down
		raise ActiveRecord::IrreversibleMigration
  end
end
