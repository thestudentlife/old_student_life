class StaffMembersToAuthors < ActiveRecord::Migration
  def self.up
    drop_table :staff_members
    
    change_table :users do |t|
      t.boolean :is_admin, :default => false
    end
    
    create_table :authors do |t|
      t.belongs_to :user, :null => true
      
      t.string :name
    end
    
    create_table :articles_authors, :id => false do |t|
      t.references :article, :null => false
      t.references :author, :null => false
    end
    
    drop_table :sections_staff_members
    
    create_table :sections_users, :id => false do |t|
      t.references :section, :null => false
      t.references :user, :null => false
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
