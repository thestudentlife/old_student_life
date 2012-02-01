class DropLegacyArticles < ActiveRecord::Migration
  def self.up
		drop_table :legacy_articles
  end

  def self.down
		raise ActiveRecord::IrreversibleMigration
  end
end
