class CreateReviewSlots < ActiveRecord::Migration
  def self.up
    create_table :review_slots do |t|
      t.string :name
      t.boolean :requires_admin, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :review_slots
  end
end
