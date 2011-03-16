class RemoveEditorsFromSections < ActiveRecord::Migration
  def self.up
    drop_table :sections_users
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
