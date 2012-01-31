class Author < ActiveRecord::Base
  
  belongs_to :user
  has_and_belongs_to_many :articles
  validates :name, :presence => true

  def self.alphabetical
    all.sort_by do |author|
      author.name.downcase
    end
  end

  def self.open_authors
    find_all_by_user_id nil
  end

  def slug
    "#{id}#{name.gsub(/\s/,'').gsub(/\./,'').downcase}"
  end

  def to_s
    name
  end

end
