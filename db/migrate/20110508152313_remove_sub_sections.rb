class RemoveSubSections < ActiveRecord::Migration
  def self.up
    drop_table :subsections
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
