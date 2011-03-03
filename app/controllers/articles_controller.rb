class ArticlesController < ApplicationController
  
  before_filter :require_user
  
  def index
    staff_member = current_user.staff_member
    if staff_member.is_admin
      @articles = Article.all
    else
      @articles = staff_member.articles
      if not (sections = staff_member.sections).empty?
        sections.map {|s| @articles += s.articles }
        @articles.uniq!
      end
    end
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
    @workflow_history_views = @article.workflow_history.map do |item|
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