class Workflow::ArticlesController < WorkflowController
  respond_to :html
  
  before_filter :require_user
  
  def index
    respond_with :workflow, @articles = Article.all
  end
  def new
    @workflow_statuses = current_user.available_workflow_statuses
    @sections = Section.all
    @subsections = Subsection.all
    respond_with :workflow, @article = Article.new
  end
  def create
    respond_with :workflow, @article = Article.create(params[:article])
  end
  def show
    respond_with :workflow, @article = Article.find(params[:id])
  end
  def edit
    @article = Article.find params[:id]
    
    if not @article.workflow_status.requires_admin or current_user.is_admin
      @workflow_statuses = current_user.available_workflow_statuses
    end
    @subsections = @article.section.subsections
    respond_with :workflow, @article
  end
  def update
    @article = Article.find params[:id]
    workflow_statuses = current_user.available_workflow_statuses.map(&:id)
    if not workflow_statuses.include? params[:article][:workflow_status_id].to_i
      params[:article].delete :workflow_status_id
    end
    
    workflow_update = WorkflowUpdate.new_for_article_params(@article, params[:article])
    workflow_update.author = current_user
    
    if @article.update_attributes params[:article] and (workflow_update.updates.any? ? workflow_update.save : true)
      redirect_to workflow_article_path(@article), :notice => "Article was successfully updated"
    else
      @subsections = current_user.open_sections.map(&:subsections).flatten
      render :action => "edit"
    end
  end
end