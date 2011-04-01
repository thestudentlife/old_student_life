class CreateInCopyArticles < ActiveRecord::Migration
  def self.up
    create_table :in_copy_articles do |t|
      t.belongs_to :article

      t.string :header
      t.string :lockfile

      t.timestamps
    end
  end

  def self.down
    drop_table :in_copy_articles
  end
end
