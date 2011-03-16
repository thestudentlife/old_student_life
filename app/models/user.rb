class User < ActiveRecord::Base
  class NotAuthorized < Exception; end
  
  acts_as_authentic
  
  has_one :author
  has_and_belongs_to_many :sections
  
  def self.dummy_password
    "somelongdummypassword"
  end
  
  def reset_password
    random_string(8).tap do |pass|
      self.attributes = {
        :password => pass,
        :password_confirmation => pass
      }
    end
  end
  
  def available_workflow_statuses
    if is_admin
      return WorkflowStatus.all
    else
      return WorkflowStatus.where(:requires_admin => false)
    end
  end
  
  def is_editor
    sections.any?
  end
  
  def is_editor_for (article)
    sections.include? article.section
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
    return true if is_admin
    # TODO return true if self.is_editor (article)
    return true if is_editor_for article
    false
  end
  
  def can_see_article (article)
    return true if is_admin
    return true if author and article.authors.include? author
    return true if is_editor_for article
    false
  end
  
  def can_see_article! (article)
    can_see_article(article) or raise NotAuthorized
  end
  
  def can_edit_article (article)
    return true if is_admin
    return true if is_editor_for article
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
    return true if is_admin 
    return true if article.open_to_author or article.workflow_status.open_to_author
    return true if is_editor_for article
    false
  end
  
  def can_post_to_article! (article)
    can_post_to_article(article) or raise NotAuthorized
  end
  
  def can_edit_authors
    is_admin or is_editor
  end
  
  def can_edit_authors!
    can_edit_authors or raise NotAuthorized
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
  
  def to_s
    email
  end
  
  private
  def random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
end
