class DropArticleStaffMembersJoin < ActiveRecord::Migration
  def self.up
    drop_table :articles_staff_members
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
