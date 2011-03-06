class Workflow::WorkflowCommentsController < WorkflowController
  
  before_filter :require_user, :find_article
  before_filter {current_user.can_post_to_article! @article}
  
  # GET /workflow_comments/new
  # GET /workflow_comments/new.xml
  def new
    @workflow_comment = WorkflowComment.new
  end

  def create
    params[:workflow_comment][:author_id] = current_user.id
    @workflow_comment = WorkflowComment.new(params[:workflow_comment])
    @workflow_comment.article = @article
    @workflow_comment.visible_to_article_author = (@article.open_to_author or @article.workflow_status.open_to_author)
    
    if @workflow_comment.save
      redirect_to workflow_article_path(@article), :notice => 'Comment was successfully created.'
    else
      render :action => "new"
    end
  end
  
  private
  def find_article
    @article = Article.find params[:article_id]
  end
end
