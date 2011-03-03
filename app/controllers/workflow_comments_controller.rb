class WorkflowCommentsController < ApplicationController
  # GET /workflow_comments/new
  # GET /workflow_comments/new.xml
  def new
    @workflow_comment = WorkflowComment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @workflow_comment }
    end
  end

  def edit
    @article = Article.find(params[:article_id])
    @workflow_comment = @article.workflow_comments.find(params[:id])
  end

  def create
    params[:workflow_comment][:article_id] = params[:article_id]
    params[:workflow_comment][:author_id] = current_user.staff_member.id
    @workflow_comment = WorkflowComment.new(params[:workflow_comment])
    
    if @workflow_comment.save
      redirect_to("/articles/#{params[:article_id]}", :notice => 'Comment was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /workflow_comments/1
  # PUT /workflow_comments/1.xml
  def update
    @workflow_comment = WorkflowComment.find(params[:id])

    respond_to do |format|
      if @workflow_comment.update_attributes(params[:workflow_comment])
        format.html { redirect_to(@workflow_comment, :notice => 'Workflow comment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @workflow_comment.errors, :status => :unprocessable_entity }
      end
    end
  end
end
