class WorkflowCommentsController < ApplicationController
  # GET /workflow_comments
  # GET /workflow_comments.xml
  def index
    @workflow_comments = WorkflowComment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @workflow_comments }
    end
  end

  # GET /workflow_comments/1
  # GET /workflow_comments/1.xml
  def show
    @workflow_comment = WorkflowComment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @workflow_comment }
    end
  end

  # GET /workflow_comments/new
  # GET /workflow_comments/new.xml
  def new
    @workflow_comment = WorkflowComment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @workflow_comment }
    end
  end

  # GET /workflow_comments/1/edit
  def edit
    @workflow_comment = WorkflowComment.find(params[:id])
  end

  # POST /workflow_comments
  # POST /workflow_comments.xml
  def create
    @workflow_comment = WorkflowComment.new(params[:workflow_comment])

    respond_to do |format|
      if @workflow_comment.save
        format.html { redirect_to(@workflow_comment, :notice => 'Workflow comment was successfully created.') }
        format.xml  { render :xml => @workflow_comment, :status => :created, :location => @workflow_comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @workflow_comment.errors, :status => :unprocessable_entity }
      end
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

  # DELETE /workflow_comments/1
  # DELETE /workflow_comments/1.xml
  def destroy
    @workflow_comment = WorkflowComment.find(params[:id])
    @workflow_comment.destroy

    respond_to do |format|
      format.html { redirect_to(workflow_comments_url) }
      format.xml  { head :ok }
    end
  end
end
