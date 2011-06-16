class CreateWorkflowArticles < ActiveRecord::Migration
  def self.up
    create_table :workflow_articles do |t|
      t.belongs_to :article
      
      t.string :status_message
      t.string :name
      t.belongs_to :locked_by
      t.text :proposed_titles
      

      t.timestamps
    end
    
    Article.all.each do |a|
      puts "Name: #{a.name}"
      puts "Locked by: #{a.locked_by}"
      
      WorkflowArticle.create!(
        :article => a,
        :status_message => a.status_message,
        :name => a.name,
        :locked_by => (a.locked_by and User.find(a.locked_by)),
        :proposed_titles => a.titles)
    end
    
    remove_column :articles, :status_message
    remove_column :articles, :name
    remove_column :articles, :locked_by
    remove_column :articles, :titles
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
