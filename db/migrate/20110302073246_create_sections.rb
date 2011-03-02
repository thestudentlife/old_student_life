class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :name, :null => false
      t.integer :priority, :unique => true, :null => false

      t.timestamps
    end
    change_table :articles do |t|
      t.belongs_to :section
    end
  end

  def self.down
    change_table :articles do |t|
      t.remove :section
    end
    drop_table :sections
  end
end
