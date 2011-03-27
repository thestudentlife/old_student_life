class Workflow::FrontPageArticlesController < WorkflowController
  inherit_resources
  actions :all, :except => [:show, :new, :create]

  before_filter {current_user.can_edit_front_page!}

  def update
    update! { workflow_front_page_articles_path }
  end
end
