class AddPhotographerDataToWorkflowArticles < ActiveRecord::Migration
  def self.up
  	add_column :workflow_articles, :has_photographer, :bool
  	add_column :workflow_articles, :photographer_name, :string
  	add_column :workflow_articles, :is_photo_submitted, :bool
  	add_column :workflow_articles, :is_photo_edited, :bool
  end

  def self.down
  	remove_column :workflow_articles, :has_photographer
  	remove_column :workflow_articles, :photographer_name
  	remove_column :workflow_articles, :is_photo_submitted
  	remove_column :workflow_articles, :is_photo_edited
  end
end