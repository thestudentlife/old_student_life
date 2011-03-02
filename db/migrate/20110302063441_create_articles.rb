class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :working_name
      t.string :status_message
      
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
