class AddLegacyIdToAuthors < ActiveRecord::Migration
  def self.up
	add_column :authors, :legacy_id, :integer
  end

  def self.down
	remove_column :authors, :legacy_id
  end
end
