class Workflow::ArticlesController < WorkflowController
  respond_to :html
  before_filter do
    @article = Article.find params[:id]
  end
  
  def show
    redirect_to workflow_article_revisions_path(@article)
  end
  
  def edit
    respond_with :workflow, @article, :revisions
  end
  def update
    workflow_update = WorkflowUpdate.new_for_article_params(@article, params[:workflow_article])
    workflow_update.author = current_user
    
    if @article.workflow.update_attributes params[:workflow_article] and (workflow_update.updates.any? ? workflow_update.save : true)
      redirect_to workflow_article_revisions_path(@article), :notice => "Article was successfully updated"
    else
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
    workflow = @article.workflow
    workflow.lock(current_user)
    if workflow.save
      flash[:notice] = 'Article was successfully locked'
    else
      flash[:warning] = 'Could not lock article'
    end
    redirect_to workflow_article_revisions_path(@article)
  end
  
  def unlock
    workflow = @article.workflow
    workflow.unlock
    if workflow.save
      flash[:notice] = 'Article was successfully unlocked'
    else
      flash[:warning] = 'Could not unlock article'
    end
    redirect_to workflow_article_revisions_path(@article)
  end
end