class StaffMember < ActiveRecord::Base
  belongs_to :user
  
  has_and_belongs_to_many :sections
  has_and_belongs_to_many :articles
  
  def visible_articles
    if is_admin
      return Article.all
    else
      visible_articles = articles
      if not sections.empty?
        sections.map {|s| visible_articles += s.articles }
        visible_articles.uniq!
      end
      return visible_articles
    end
  end
  
  def can_see_article (article)
    return true if self.is_admin
    return true if article.authors.include? self
    return true if self.sections.include? article.section
    return false
  end
  
  def email
    user.email
  end
  def to_s
    email
  end
end
