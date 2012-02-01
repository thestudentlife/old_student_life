class DropInCopyArticles < ActiveRecord::Migration
  def self.up
		drop_table :in_copy_articles
  end

  def self.down
		raise ActiveRecord::IrreversibleMigration
  end
end
