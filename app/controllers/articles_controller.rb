class ArticlesController < ApplicationController
  def index
    @headlines = Revision.latest_headlines.includes(:article)
    @revisions = Revision.latest_published_not_in_headlines.includes(:article)
  end
  def show
    @article = Article.find params[:id]
    @revision = @article.latest_published_revision
  end
end
