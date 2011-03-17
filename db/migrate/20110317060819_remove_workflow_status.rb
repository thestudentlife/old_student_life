class RemoveWorkflowStatus < ActiveRecord::Migration
  def self.up
    drop_table :workflow_statuses
    remove_column :articles, :workflow_status_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
