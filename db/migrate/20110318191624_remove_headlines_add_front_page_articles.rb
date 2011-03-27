class RemoveHeadlinesAddFrontPageArticles < ActiveRecord::Migration
  def self.up
    drop_table :headlines
    create_table :front_page_articles do |t|
      t.belongs_to :article, :null => false
      t.integer :priority
      
      t.timestamps
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
