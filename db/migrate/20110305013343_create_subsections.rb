class CreateSubsections < ActiveRecord::Migration
  def self.up
    create_table :subsections do |t|
      t.belongs_to :section
      
      t.string :name
      t.integer :priority

      t.timestamps
    end
  end

  def self.down
    drop_table :subsections
  end
end
