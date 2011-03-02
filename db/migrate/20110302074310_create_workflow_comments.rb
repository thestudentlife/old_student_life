class CreateWorkflowComments < ActiveRecord::Migration
  def self.up
    create_table :workflow_comments do |t|
      t.belongs_to :article
      t.boolean :visible_to_author
      
      t.string :text

      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_comments
  end
end
