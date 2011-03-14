class Workflow::WorkflowStatusesController < WorkflowController
  respond_to :html
  
  before_filter :require_user
  before_filter {current_user.can_edit_workflow_statuses!}
  
  def index
    respond_with :workflow, @workflow_statuses = WorkflowStatus.all
  end

  def new
    respond_with :workflow, @workflow_status = WorkflowStatus.new
  end

  def edit
    respond_with :workflow, @workflow_status = WorkflowStatus.find(params[:id])
  end

  def create
    respond_with :workflow,
      @workflow_status= WorkflowStatus.create(params[:workflow_status]),
      :location => [:workflow, :statuses]
  end

  def update
    respond_with :workflow,
      @workflow_status = WorkflowStatus.update(params[:id], params[:workflow_status]),
      :location => [:workflow, :statuses]
  end
end
