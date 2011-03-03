class ArticlesController < ApplicationController
  def index
    @revisions = Revision.latest_published.includes(:article)
  end
  def show
    @article = Article.find params[:id]
    @revision = @article.latest_published_revision
  end
end
