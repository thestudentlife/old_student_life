class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :working_name
      t.string :status_message
      
      t.boolean :open_to_author, :default => true
      t.boolean :publishable, :default => false
      t.boolean :visible, :default => true
      
      t.belongs_to :headline, :null => true
      t.belongs_to :section, :null => true
      t.belongs_to :subsection
      
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
