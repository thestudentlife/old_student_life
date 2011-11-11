class AddVideoTextToArticles < ActiveRecord::Migration
  def self.up
		add_column :articles, :video_youtube_id, :string, :limit => 50
  end

  def self.down
		remove_column :articles, :video_youtube_id
  end
end
