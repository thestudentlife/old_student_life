class AddLockfileContentToInCopyArticle < ActiveRecord::Migration
  def self.up
    add_column :in_copy_articles, :lockfile_content, :string
  end

  def self.down
    remove_column :in_copy_articles, :lockfile_content
  end
end
