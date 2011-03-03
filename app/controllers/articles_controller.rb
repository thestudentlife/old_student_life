class ArticlesController < ApplicationController
  
  before_filter :require_user
  
  def index
    staff_member = current_user.staff_member
    @articles = staff_member.visible_articles
  end
  def new
    @article = Article.new
    @workflow_statuses = WorkflowStatus.all
    @sections = Section.all
  end
  def create
    @article = Article.new params[:article]
    
    if @article.save
      redirect_to @article, :notice => "Article was successfully created"
    else
      render :action => "new"
    end
  end
  def show
    @article = Article.find params[:id]
    staff_member = current_user.staff_member
    if not staff_member.can_see_article @article
      raise ActiveRecord::RecordNotFound
    end
    
    @editable = staff_member.can_edit_article @article
    @postable = staff_member.can_post_to_article @article
    
    @workflow_history_views = \
    staff_member.visible_workflow_history_for (@article).map do |item|
      slug = item.class.name.underscore
      render_to_string :partial => slug, :locals => {slug.to_sym => item}
    end
  end
  def edit
    @article = Article.find params[:id]
    @workflow_statuses = WorkflowStatus.all
    @sections = Section.all
  end
  def update
    @article = Article.find params[:id]
    if @article.update_attributes params[:article]
      redirect_to @article, :notice => "Article was successfully updated"
    else
      render :action => "edit"
    end
  end
end