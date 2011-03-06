class Workflow::WorkflowStatusesController < WorkflowController
  
  before_filter :require_user
  before_filter {current_user.can_edit_workflow_statuses!}
  
  def index
    @workflow_statuses = WorkflowStatus.all
  end

  def new
    @workflow_status = WorkflowStatus.new
  end

  def edit
    @workflow_status = WorkflowStatus.find params[:id]
  end

  def create
    @workflow_status = WorkflowStatus.new params[:workflow_status]

    if @workflow_status.save
      redirect_to workflow_statuses_path, :notice => 'Workflow status was successfully created.'
    else
      render :action => "new"
    end
  end

  def update
    @workflow_status = WorkflowStatus.find params[:id]

    if @workflow_status.update_attributes params[:workflow_status]
      redirect_to workflow_statuses_path, :notice => 'Workflow status was successfully updated.'
    else
      render :action => "edit"
    end
  end
end
