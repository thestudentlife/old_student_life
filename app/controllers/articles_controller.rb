class ArticlesController < ApplicationController
  def index
    @front_page_revisions = Revision.latest_published_on_front_page.includes(:article)
    @revisions = Revision.latest_published_not_on_front_page.includes(:article)
  end
  def show
    @article = Article.find params[:id]
    @revision = @article.latest_published_revision
  end
end
