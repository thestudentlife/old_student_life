class Workflow::Articles::RevisionsController < WorkflowController

  respond_to :html
  before_filter :require_user
  before_filter { @article = Article.find params[:article_id] }

  def new
    respond_with :workflow, @revision = Revision.new
  end

  def edit
    @revision = @article.revisions.find(params[:id])
    current_user.can_publish_revision! @revision
    respond_with :workflow, @revision
  end

  def create
    params[:revision] ||= {}
    params[:revision][:body] = params["wmd-input"]
    @revision = Revision.new(params[:revision])
    @revision.article = @article
    @revision.author = current_user
    @revision.save
    
    respond_with :workflow, @revision, :location => [:workflow, @article]
  end

  def update
    @revision = Revision.update(params[:id], params[:revision])
    respond_with :workflow, @revision, :location => workflow_article_path(@revision.article_id)
  end
end
