class Issue < ActiveRecord::Base
  has_many :articles
  
  def to_s
    name
  end
  
  def davslug
    s = to_s.gsub('/','-')
    "#{id} #{s}"
  end
  def sections
    Section.joins(:articles => :issue).where(:issues => {:id => id}).group(:sections => :id)
  end
end
