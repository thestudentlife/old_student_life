class Workflow::Articles::CommentsController < WorkflowController
  respond_to :html
  
  before_filter { @article = Article.find params[:article_id] }
  
  def new
    respond_with :workflow, @workflow_comment = WorkflowComment.new
  end

  def create
    @workflow_comment = WorkflowComment.create params[:workflow_comment].merge({
      :article => @article,
      :author_id => current_user.id
    })
    
    respond_with :workflow, @workflow_comment, :location => [:workflow, @article, :revisions]
  end
end
