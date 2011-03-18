class Author < ActiveRecord::Base
  
  belongs_to :user
  has_and_belongs_to_many :articles
  validates_presence_of :name

  def latest_published_revisions
    Revision.latest_published.joins(
      :article,
      'LEFT JOIN "articles_authors" ON "articles_authors"."article_id" = "articles"."id"',
      'LEFT JOIN "authors" ON "authors"."id" = "articles_authors"."author_id"'
    ).where("authors.id" => id)
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
