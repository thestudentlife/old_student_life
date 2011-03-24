class Issue < ActiveRecord::Base
  has_many :articles
  
  def to_s
    name
  end
  
  def slug
    t = to_s.to_slug.gsub(/(^-)|(-$)/,'')
    "#{id}-#{t}"
  end
end
