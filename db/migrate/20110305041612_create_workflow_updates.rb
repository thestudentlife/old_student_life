class CreateWorkflowUpdates < ActiveRecord::Migration
  def self.up
    create_table :workflow_updates do |t|
      t.belongs_to :article, :null => false
      t.belongs_to :author, :null => false
      t.boolean :visible_to_article_author, :default => true
      
      t.string :updates

      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_updates
  end
end