class ArticleBelongsToWorkflowStatus < ActiveRecord::Migration
  def self.up
    change_table :articles do |t|
      t.belongs_to :workflow_status
    end
  end

  def self.down
    change_table :articles do |t|
      t.remove :workflow_status
    end
  end
end
