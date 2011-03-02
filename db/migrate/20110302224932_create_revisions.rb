class CreateRevisions < ActiveRecord::Migration
  def self.up
    create_table :revisions do |t|
       t.belongs_to :article
        t.boolean :visible_to_author

        t.string :title
        t.text :body
        
        t.boolean :published_online, :default => false
        t.boolean :published_online_at, :false => true
        
        t.boolean :published_in_print, :default => false
        t.boolean :published_in_print_at, :false => true

      t.timestamps
    end
  end

  def self.down
    drop_table :revisions
  end
end