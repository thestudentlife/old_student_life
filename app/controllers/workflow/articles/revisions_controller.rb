class Workflow::Articles::RevisionsController < WorkflowController

  before_filter :require_user
  before_filter { @article = Article.find params[:article_id] }

  def new
    @revision = Revision.new
  end

  def edit
    @revision = @article.revisions.find(params[:id])
  end

  def create
    params[:revision][:body] = params["wmd-input"]
    @revision = Revision.new(params[:revision])
    @revision.article = @article
    @revision.author = current_user
    @revision.visible_to_article_author = (@article.open_to_author or @article.workflow_status.open_to_author)
    
    if @revision.save
      redirect_to workflow_article_path(@article), :notice => 'Revision was successfully created.'
    else
      render :action => "new"
    end
  end

  def update
    @revision = Revision.find(params[:id])

      if @revision.update_attributes(params[:revision])
        redirect_to workflow_article_path(@revision.article_id), :notice => 'Revision was successfully updated.'
      else
        render :action => "edit"
      end
  end
end
