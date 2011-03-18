class Workflow::ArticlesController < WorkflowController
  respond_to :html
  before_filter { @article = Article.find params[:id] }
  
  def show
    respond_with :workflow, @article
  end
  def edit
    @subsections = @article.section.subsections
    respond_with :workflow, @article
  end
  def update
    workflow_update = WorkflowUpdate.new_for_article_params(@article, params[:article])
    workflow_update.author = current_user
    
    
    if @article.update_attributes params[:article] and (workflow_update.updates.any? ? workflow_update.save : true)
      redirect_to workflow_article_path(@article), :notice => "Article was successfully updated"
    else
      @subsections = @article.section.map(&:subsections).flatten
      render :action => "edit"
    end
  end
end