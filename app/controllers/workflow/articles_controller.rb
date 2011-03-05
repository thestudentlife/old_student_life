class Workflow::ArticlesController < WorkflowController
  
  before_filter :require_user
  
  def index
    @articles = current_staff_member.visible_articles
  end
  def new
    current_staff_member.can_create_articles!
    @article = Article.new
    @workflow_statuses = current_staff_member.available_workflow_statuses
    @sections = current_staff_member.open_sections.includes(:subsections)
    @subsections = @sections.map(&:subsections).flatten
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
    
    if not @article.workflow_status.requires_admin or current_staff_member.is_admin
      @workflow_statuses = current_staff_member.available_workflow_statuses
    end
    @subsections = @article.section.subsections
  end
  def update
    @article = Article.find params[:id]
    current_staff_member.can_edit_article! @article
    workflow_statuses = current_staff_member.available_workflow_statuses.map(&:id)
    if not workflow_statuses.include? params[:article][:workflow_status_id].to_i
      params[:article].delete :workflow_status_id
    end
    
    workflow_update = WorkflowUpdate.new_for_article_params(@article, params[:article])
    workflow_update.author = current_staff_member
    
    if @article.update_attributes params[:article] and (workflow_update.updates.any? ? workflow_update.save : true)
      redirect_to workflow_article_path(@article), :notice => "Article was successfully updated"
    else
      @subsections = current_staff_member.open_sections.map(&:subsections).flatten
      render :action => "edit"
    end
  end
end