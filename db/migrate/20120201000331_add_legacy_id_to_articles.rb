class AddLegacyIdToArticles < ActiveRecord::Migration
  def self.up
		add_column :articles, :legacy_id, :integer
  end

  def self.down
		remove_column :articles, :legacy_id
  end
end
