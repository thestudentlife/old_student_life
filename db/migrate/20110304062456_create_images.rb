class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.belongs_to :article, :null => false
      t.boolean :published_online, :default => false
      t.boolean :published_in_print, :default => false
      
      t.string :file_file_name
      t.string :file_content_type
      t.integer :file_file_size
      t.datetime :file_updated_at
    end
  end

  def self.down
    drop_table :images
  end
end
