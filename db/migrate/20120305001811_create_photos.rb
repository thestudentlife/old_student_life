class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.belongs_to :photo_set, :null => false
      
      t.string :caption
      t.string :credit
      
      t.string :file_file_name
      t.string :file_content_type
      t.integer :file_file_size
      t.datetime :file_updated_at
    end
  end

  def self.down
    drop_table :photos
  end
end
