class Workflow::WorkflowStatusesController < ApplicationController
  # GET /workflow_statuses
  def index
    @workflow_statuses = WorkflowStatus.all
  end

  # GET /workflow_statuses/1
  def show
    @workflow_status = WorkflowStatus.find params[:id]
  end

  # GET /workflow_statuses/new
  def new
    @workflow_status = WorkflowStatus.new
  end

  # GET /workflow_statuses/1/edit
  def edit
    @workflow_status = WorkflowStatus.find params[:id]
  end

  # POST /workflow_statuses
  def create
    @workflow_status = WorkflowStatus.new params[:workflow_status]

    if @workflow_status.save
      redirect_to @workflow_status, :notice => 'Workflow status was successfully created.'
    else
      render :action => "new"
    end
  end

  # PUT /workflow_statuses/1
  def update
    @workflow_status = WorkflowStatus.find params[:id]

    if @workflow_status.update_attributes params[:workflow_status]
      redirect_to @workflow_status, :notice => 'Workflow status was successfully updated.'
    else
      render :action => "edit"
    end
  end
end
