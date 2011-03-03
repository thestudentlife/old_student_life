class CreateStaffMembers < ActiveRecord::Migration
  def self.up
    create_table :staff_members do |t|
      t.belongs_to :user, :null => true
      t.boolean :is_admin, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :staff_members
  end
end
