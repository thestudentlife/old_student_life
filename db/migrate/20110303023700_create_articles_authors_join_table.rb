class CreateArticlesAuthorsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :articles_staff_members, :id => false do |t|
      t.references :article, :null => false
      t.references :staff_member, :null => false
    end
  end

  def self.down
    drop_table :articles_staff_members
  end
end
