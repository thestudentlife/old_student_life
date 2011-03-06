class AddNameToStaffMembers < ActiveRecord::Migration
  def self.up
    change_table :staff_members do |t|
      t.string :name
    end
  end

  def self.down
    change_table :staff_members do |t|
      t.remove :name
    end
  end
end
