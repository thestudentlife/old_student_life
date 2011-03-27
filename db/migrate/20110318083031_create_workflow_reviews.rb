class CreateWorkflowReviews < ActiveRecord::Migration
  def self.up
    create_table :workflow_reviews do |t|
      t.belongs_to :review_slot, :null => false
      t.belongs_to :article, :null => false
      
      t.string :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_reviews
  end
end
