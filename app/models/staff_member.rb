class StaffMember < ActiveRecord::Base
  class NotAuthorized < Exception; end
  
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
  
  def available_workflow_statuses
    if is_admin
      return WorkflowStatus.all
    else
      return WorkflowStatus.where(:requires_admin => false)
    end
  end
  
  def visible_articles
    if is_admin
      Article.order("created_at DESC")
    else
      visible_articles = articles
      if not sections.empty?
        sections.map {|s| visible_articles += s.articles }
        visible_articles.uniq!
      end
      visible_articles.sort_by(&:created_at).reverse
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
  
  def open_sections
    is_admin ? Section.all : sections
  end
  
  def can_create_articles
    return true if is_admin
    return true if sections.any?
    false
  end
  def can_create_articles!
    can_create_articles or raise NotAuthorized
  end
  
  def can_create_article_with_params (params)
    return true if is_admin
    open_sections.map(&:id).include? params[:section_id].to_i
  end
  
  def can_create_article_with_params! (params)
    can_create_article_with_params(params) or raise NotAuthorized
  end
  
  def can_see_article_images (article)
    return true if self.is_admin
    # TODO return true if self.is_editor (article)
    return true if self.sections.include? article.section
    false
  end
  
  def can_see_article (article)
    return true if self.is_admin
    return true if article.authors.include? self
    return true if self.sections.include? article.section
    false
  end
  
  def can_see_article! (article)
    can_see_article(article) or raise NotAuthorized
  end
  
  def can_edit_article (article)
    return true if self.is_admin
    return true if self.sections.include? article.section
    false
  end
  def can_edit_article! (article)
    can_edit_article(article) or raise NotAuthorized
  end
  
  def can_publish_article (article)
    return true if is_admin
    return true if article.publishable or article.workflow_status.publishable
    return false
  end
  
  def can_override_workflow
    is_admin
  end
  
  def can_post_to_article (article)
    return true if self.is_admin 
    return true if article.open_to_author or article.workflow_status.open_to_author
    return true if self.sections.include? article.section
    false
  end
  
  def can_post_to_article! (article)
    can_post_to_article(article) or raise NotAuthorized
  end
  
  [
    :headlines,
    :sections,
    :workflow_statuses,
    :users
  ].map{ |m|
    "can_edit_#{m}"
  }.each do |permission|
    define_method(permission) do 
      is_admin
    end
    define_method("#{permission}!") do
      send(permission) or raise NotAuthorized
    end
  end
  
  def email
    user.email
  end
  def to_s
    unless name.nil? or name.empty?
      name
    else
      email
    end
  end
end
