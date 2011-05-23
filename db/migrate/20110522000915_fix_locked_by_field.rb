class FixLockedByField < ActiveRecord::Migration
  def self.up
    remove_column :workflow_articles, :locked_by_id
    add_column :workflow_articles, :locked_by, :integer
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
