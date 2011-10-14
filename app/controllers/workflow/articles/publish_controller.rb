class Workflow::Articles::PublishController < WorkflowController
  before_filter do @article = Article.find params[:article_id] end
  respond_to :html
   
  def show
    if @article.latest_revision.nil?
      flash[:error] = "You must create at least one revision before publishing this article"
      return redirect_to [:workflow, @article, :revisions]
    end
    
    @article.published_at = Time.zone.now unless @article.published?
    respond_with @article
  end
  
  def update
    params[:article][:published] = true
    @article.update_attributes params[:article]
    respond_with @article, :location => workflow_article_revisions_path(@article)
  end
  
  def destroy
    @article.update_attributes :published => false
    respond_with @article, :location => workflow_article_revisions_path(@article)
  end
  
end
