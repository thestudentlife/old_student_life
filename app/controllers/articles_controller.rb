class ArticlesController < ApplicationController
  def index
    @headlines = Revision.latest_headlines.includes(:article)
    @revisions = Revision.latest_published_not_in_headlines.includes(:article)
    
    @most_viewed = ViewedArticle.latest_most_viewed(10)
  end
  def show
    @article = Article.find params[:id]
    @revision = @article.latest_published_revision
    
    # This might fail. If it does, it shouldn't effect the render.
    # There's gotta be logging functionality around here somewhere..
    ViewedArticle.new(:article => @article).save
  end
end
