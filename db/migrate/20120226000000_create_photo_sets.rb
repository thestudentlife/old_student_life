class CreatePhotoSets < ActiveRecord::Migration
  def self.up
    create_table(:photo_sets) do |t|
      t.text :description
      t.references :article
      
      t.timestamps
    end
  end

  def self.down
    drop_table :photo_sets
  end
end
