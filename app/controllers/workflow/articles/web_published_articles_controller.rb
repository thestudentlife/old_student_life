class Workflow::Articles::WebPublishedArticlesController < WorkflowController
  inherit_resources
  actions :new, :create, :destroy
  before_filter do @article = Article.find params[:article_id] end
   
  def new
    if @article.latest_revision.nil?
      flash[:error] = "You must create at least one revision before publishing this article"
      return redirect_to [:workflow, @article]
    end
    
    @web_published_article = WebPublishedArticle.new(
      :published_at => (Time.now - 7.hours)
    )
    respond_with @web_published_article
  end
  
  def create
    @web_published_article = WebPublishedArticle.create params[:web_published_article].merge(
      :article_id => @article.id
    )
    respond_with @web_published_article, :location => workflow_article_path(@article)
  end
  
  def destroy
    @web_published_article = WebPublishedArticle.find params[:id]
    @web_published_article.destroy
    respond_with @web_published_article, :location => workflow_article_path(@article)
  end
  
end
