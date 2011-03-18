class Workflow::FrontPageArticlesController < WorkflowController
  inherit_resources
  actions :all, :except => [:show, :new, :create]

  before_filter :require_user
  before_filter {current_user.can_edit_front_page!}

  def update
    update! { workflow_front_page_path }
  end
end
