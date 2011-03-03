class Workflow::WorkflowCommentsController < ApplicationController
  
  before_filter :find_article
  
  # GET /workflow_comments/new
  # GET /workflow_comments/new.xml
  def new
    @workflow_comment = WorkflowComment.new
  end

  def edit
    @workflow_comment = @article.workflow_comments.find(params[:id])
  end

  def create
    params[:workflow_comment][:author_id] = current_user.staff_member.id
    @workflow_comment = WorkflowComment.new(params[:workflow_comment])
    @workflow_comment.article = @article
    @workflow_comment.visible_to_article_author = @article.open_to_author
    
    if @workflow_comment.save
      redirect_to workflow_article_path(@article), :notice => 'Comment was successfully created.'
    else
      render :action => "new"
    end
  end

  # PUT /workflow_comments/1
  # PUT /workflow_comments/1.xml
  def update
    @workflow_comment = WorkflowComment.find(params[:id])

      if @workflow_comment.update_attributes params[:workflow_comment]
        redirect_to @workflow_comment, :notice => 'Workflow comment was successfully updated.'
      else
        render :action => "edit"
      end
  end
  
  private
  def find_article
    @article = Article.find params[:article_id]
  end
end
