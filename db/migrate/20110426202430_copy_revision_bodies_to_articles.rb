class CopyRevisionBodiesToArticles < ActiveRecord::Migration
  def self.up
    Article.includes(:revisions).all.each do |a|
      a.latest_revision.try(:save!)
    end
  end

  def self.down
  end
end
