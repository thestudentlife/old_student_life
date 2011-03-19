class Workflow::Articles::ReviewsController < WorkflowController
  inherit_resources
  actions :new, :create
  defaults :resource_class => WorkflowReview
  belongs_to :article
  
  def create
    params[:workflow_review][:author_id] = current_user.id
    create! { workflow_article_path @article }
  end
end
