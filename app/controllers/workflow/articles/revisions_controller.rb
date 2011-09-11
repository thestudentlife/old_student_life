class Workflow::Articles::RevisionsController < WorkflowController
  inherit_resources
  belongs_to :article
  
  def index
    show
    render :show
  end
  
  def show
    @article = Article.find params[:article_id]
    @revision = params[:id] ? Revision.find(params[:id]) : @article.latest_revision
  end
  
  def new
    new! do
      workflow = @article.workflow
      if (not workflow.locked?) or (workflow.locked? and workflow.locked_by != current_user)
        flash[:error] = 'You must lock an article before editing it.'
        redirect_to [:workflow, @article, :revisions] and return
      end
      if @article.revisions.latest.any?
        @revision.body = @article.latest_revision.body
      end
    end
  end
  
  def create
    params[:revision].merge!(
      :article => @article,
      :author => current_user
    )
    create! { [:workflow, @article, :revisions] }
  end
  
  def body
    @article = Article.find params[:article_id]
    @revision = @article.latest_revision
    render :layout => false
  end
end
