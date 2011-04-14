class ChangeInCopyContentFromStringToBody < ActiveRecord::Migration
  def self.up
    remove_column :in_copy_articles, :header
    add_column :in_copy_articles, :header, :text
  end

  def self.down
    remove_column :in_copy_articles, :header
    add_column :in_copy_articles, :header, :string
  end
end
