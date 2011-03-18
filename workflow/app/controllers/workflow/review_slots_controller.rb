class Workflow::ReviewSlotsController < WorkflowController
  inherit_resources
  actions :all, :except => [:show]  
  
  def create
    create! { workflow_review_slots_path }
  end
  
  def update
    update! { workflow_review_slots_path }
  end
  
end
