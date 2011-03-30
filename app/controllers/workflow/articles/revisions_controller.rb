class Workflow::Articles::RevisionsController < WorkflowController
  inherit_resources
  belongs_to :article
  before_filter :require_user
  
  def new
    new! do
      if (not @article.locked?) or (@article.locked? and @article.locked_by != current_user)
        flash[:notice] = 'You must lock an article before editing it.'
        redirect_to [:workflow, @article] and return
      end
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