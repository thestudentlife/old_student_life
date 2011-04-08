class Workflow::ArticlesController < WorkflowController
  respond_to :html
  before_filter do
    @article = Article.find params[:id]
    if @article.titles.nil?
      @article.titles = []
      @article.save
    end
  end
  
  def show
    redirect_to workflow_article_revisions_path(@article)
  end
  
  def edit
    @subsections = @article.section.subsections
    respond_with :workflow, @article, :revisions
  end
  def update
    workflow_update = WorkflowUpdate.new_for_article_params(@article, params[:article])
    workflow_update.author = current_user
    
    if @article.update_attributes params[:article] and (workflow_update.updates.any? ? workflow_update.save : true)
      redirect_to workflow_article_revisions_path(@article), :notice => "Article was successfully updated"
    else
      @subsections = @article.section.map(&:subsections).flatten
      render :action => "edit"
    end
  end
  
  def destroy
    current_user.can_delete_articles!
    @issue = @article.issue
    @article.destroy
    flash[:warning] = 'Article was deleted'
    redirect_to [:workflow, @issue]
  end
  
  def lock
    @article.lock(current_user)
    if @article.save
      flash[:notice] = 'Article was successfully locked'
    else
      flash[:warning] = 'Could not lock article'
    end
    redirect_to workflow_article_revisions_path(@article)
  end
  
  def unlock
    @article.unlock
    if @article.save
      flash[:notice] = 'Article was successfully unlocked'
    else
      flash[:warning] = 'Could not unlock article'
    end
    redirect_to workflow_article_revisions_path(@article)
  end
end