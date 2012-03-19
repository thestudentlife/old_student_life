class RemovePublishedColumnsFromImages < ActiveRecord::Migration
  def self.up
    remove_column :images, :published_online
    remove_column :images, :published_in_print
  end

  def self.down
    add_column :images, :published_online
    add_column :images, :published_in_print
  end
end
