class DropForms < ActiveRecord::Migration
  def self.up
		drop_table :forms
		drop_table :submissions
  end

  def self.down
		raise ActiveRecord::IrreversibleMigration
  end
end
