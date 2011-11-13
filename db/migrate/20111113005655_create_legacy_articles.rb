class CreateLegacyArticles < ActiveRecord::Migration
  def self.up
    create_table :legacy_articles do |t|
			t.references :article
    end
  end

  def self.down
    drop_table :legacy_articles
  end
end
