class AddLockFieldToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :locked_by, :integer
  end

  def self.down
    remove_column :articles, :locked_by
  end
end
