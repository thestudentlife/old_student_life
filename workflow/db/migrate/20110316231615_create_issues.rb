class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.string :name

      t.timestamps
    end
    add_column :articles, :issue_id, :integer
  end

  def self.down
    drop_table :issues
    drop_column :articles, :issue_id
  end
end
