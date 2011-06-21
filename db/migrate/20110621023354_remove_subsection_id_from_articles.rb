class RemoveSubsectionIdFromArticles < ActiveRecord::Migration
  def self.up
    remove_column :articles, :subsection_id
  end
end
