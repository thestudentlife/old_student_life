class CreateWorkflowStatuses < ActiveRecord::Migration
  def self.up
    create_table :workflow_statuses do |t|
      t.string :name
      t.integer :priority, :unique => true, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_statuses
  end
end
