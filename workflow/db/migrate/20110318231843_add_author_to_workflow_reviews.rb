class AddAuthorToWorkflowReviews < ActiveRecord::Migration
  def self.up
    add_column :workflow_reviews, :author_id, :integer
  end

  def self.down
    remove_column :workflow_reviews, :author_id
  end
end
