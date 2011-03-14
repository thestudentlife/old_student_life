class Workflow::Articles::CommentsController < WorkflowController
  respond_to :html
  
  before_filter :require_user
  before_filter { @article = Article.find params[:article_id] }
  before_filter { current_user.can_post_to_article! @article }
  
  def new
    respond_with :workflow, @workflow_comment = WorkflowComment.new
  end

  def create
    params[:workflow_comment][:author_id] = current_user.id
    @workflow_comment = WorkflowComment.create params[:workflow_comment].merge({
      :article => @article,
      :visible_to_article_author => (@article.open_to_author or @article.workflow_status.open_to_author)
    })
    
    respond_with :workflow, @workflow_comment, :location => [:workflow, @article]
  end
end
