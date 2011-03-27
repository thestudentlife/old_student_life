class CreateWorkflowStatuses < ActiveRecord::Migration
  def self.up
    create_table :workflow_statuses do |t|
      t.string :name
      
      t.boolean :requires_admin, :default => false
      
      t.boolean :open_to_author, :default => true
      t.boolean :publishable, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_statuses
  end
end
