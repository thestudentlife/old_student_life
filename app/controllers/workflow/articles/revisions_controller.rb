class Workflow::Articles::RevisionsController < WorkflowController
  inherit_resources
  belongs_to :article
  before_filter :require_user
  
  def new
    new! do
      if @article.revisions.latest.any?
        @revision.body = @article.revisions.latest.first.body
      end
    end
  end
  
  def create
    params[:revision].merge!(
      :article => @article,
      :author => current_user
    )
    create! { [:workflow, @article] }
  end
  
  def body
    @article = Article.find params[:article_id]
    @revision = @article.revisions.latest.first
    render :layout => false
  end
end
