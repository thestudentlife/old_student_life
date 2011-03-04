class StaffMember < ActiveRecord::Base
  belongs_to :user
  
  has_and_belongs_to_many :sections
  has_and_belongs_to_many :articles
  
  def latest_published_revisions
    Revision.latest_published.joins(
      :article,
      'LEFT JOIN "articles_staff_members" ON "articles_staff_members"."article_id" = "articles"."id"',
      'LEFT JOIN "staff_members" ON "staff_members"."id" = "articles_staff_members"."staff_member_id"'
    ).where("staff_members.id" => id)
  end
  
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
  
  def is_editor_for (article)
    self.sections.include? article.section
  end
  
  def visible_workflow_history_for (article)
    if is_admin or is_editor_for(article)
      article.workflow_history
    else
      article.workflow_history_visible_to_article_author
    end
  end
  
  def can_see_article (article)
    return true if self.is_admin
    return true if article.authors.include? self
    return true if self.sections.include? article.section
    false
  end
  
  def can_edit_article (article)
    return true if self.is_admin
    return true if self.sections.include? article.section
    false
  end
  
  def can_post_to_article (article)
    return true if self.is_admin
    return true if article.open_to_author
    return true if self.sections.include? article.section
    false
  end
  
  def can_edit_users
    is_admin
  end
  
  def email
    user.email
  end
  def to_s
    email
  end
end
