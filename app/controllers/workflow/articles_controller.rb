class Workflow::ArticlesController < ApplicationController
  
  before_filter :require_user
  
  def index
    @articles = current_staff_member.visible_articles
  end
  def new
    current_staff_member.can_create_articles!
    @article = Article.new
    @workflow_statuses = current_staff_member.available_workflow_statuses
    @sections = current_staff_member.open_sections.includes(:subsections)
    @subsections = @sections.map(&:subsections)
  end
  def create
    current_staff_member.can_create_articles!
    current_staff_member.can_create_article_with_params! params[:article]
    @article = Article.new params[:article]
    
    if @article.save
      redirect_to workflow_article_path(@article), :notice => "Article was successfully created"
    else
      render :action => "new"
    end
  end
  def show
    @article = Article.find params[:id]
    current_staff_member.can_see_article! @article
    
    @editable = current_staff_member.can_edit_article @article
    @postable = current_staff_member.can_post_to_article @article
    
    @workflow_history_views = \
    current_staff_member.visible_workflow_history_for(@article
    ).map do |item|
      slug = item.class.name.underscore
      render_to_string :partial => slug, :locals => {slug.to_sym => item}
    end
  end
  def edit
    @article = Article.find params[:id]
    current_staff_member.can_edit_article! @article
    
    @workflow_statuses = current_staff_member.available_workflow_statuses
    @subsections = @article.section.subsections
  end
  def update
    @article = Article.find params[:id]
    current_staff_member.can_edit_article! @article
    workflow_statuses = current_staff_member.available_workflow_statuses.map(&:id)
    if not workflow_statuses.include? params[:article][:workflow_status_id].to_i
      @article.errors.add :workflow_status_id, "is not available to this user"
    end
    
    if @article.errors.empty? and @article.update_attributes params[:article]
      redirect_to workflow_article_path(@article), :notice => "Article was successfully updated"
    else
      render :action => "edit"
    end
  end
end