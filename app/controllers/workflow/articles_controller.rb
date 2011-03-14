class Workflow::ArticlesController < WorkflowController
  respond_to :html
  
  before_filter :require_user
  
  def index
    respond_with :workflow, @articles = current_user.visible_articles
  end
  def new
    current_user.can_create_articles!
    @workflow_statuses = current_user.available_workflow_statuses
    @sections = current_user.open_sections
    @subsections = @sections.map(&:subsections).flatten
    respond_with :workflow, @article = Article.new
  end
  def create
    current_user.can_create_articles!
    current_user.can_create_article_with_params! params[:article]
    respond_with :workflow, @article = Article.create(params[:article])
  end
  def show
    @article = Article.find params[:id]
    current_user.can_see_article! @article
    
    @editable = current_user.can_edit_article @article
    @postable = current_user.can_post_to_article @article
    
    @workflow_history_views = \
    current_user.visible_workflow_history_for(@article
    ).map do |item|
      slug = item.class.name.underscore
      render_to_string :partial => slug, :locals => {slug.to_sym => item}
    end
    
    if current_user.can_see_article_images @article
      @images = @article.images
    end
    respond_with :workflow, @article
  end
  def edit
    @article = Article.find params[:id]
    current_user.can_edit_article! @article
    
    if not @article.workflow_status.requires_admin or current_user.is_admin
      @workflow_statuses = current_user.available_workflow_statuses
    end
    @subsections = @article.section.subsections
    respond_with :workflow, @article
  end
  def update
    @article = Article.find params[:id]
    current_user.can_edit_article! @article
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