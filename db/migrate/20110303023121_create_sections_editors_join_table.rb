class CreateSectionsEditorsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :sections_staff_members, :id => false do |t|
      t.references :section, :null => false
      t.references :staff_member, :null => false
    end
  end

  def self.down
    drop_table :sections_staff_members
  end
end
