class Workflow::AuthorsController < WorkflowController
  inherit_resources
  before_filter {current_user.can_edit_authors!}

  def index
    @authors = Author.alphabetical
    index!
  end

  def create
    create! { workflow_authors_path }
  end

  def update
    update! { workflow_authors_path }
  end
end
