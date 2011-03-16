class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.string :name

      t.timestamps
    end
    add_column :articles, :issue_id, :belongs_to
  end

  def self.down
    drop_table :issues
  end
end
