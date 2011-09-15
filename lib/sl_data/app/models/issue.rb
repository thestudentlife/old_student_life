class Issue < ActiveRecord::Base
  has_many :articles
  
  def to_s
    name
  end
  
  def davslug
    s = to_s.scan(/[\w\d]+/).join("-")
    "#{id}-#{s}"
  end
  def sections
    Section.joins(:articles => :issue).where(:issues => {:id => id}).group(:id)
  end
  def slug
    t = to_s.to_slug.gsub(/(^-)|(-$)/,'')
    "#{id}-#{t}"
  end
end
