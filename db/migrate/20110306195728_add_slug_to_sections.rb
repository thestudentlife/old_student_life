class AddSlugToSections < ActiveRecord::Migration
  def self.up
    change_table :sections do |t|
      t.string :url
    end
    change_table :subsections do |t|
      t.string :url
    end
  end

  def self.down
    change_table :sections do |t|
      t.remove :url
    end
    change_table :subsections do |t|
      t.remove :url
    end
  end
end
