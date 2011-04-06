class Workflow::Articles::ReviewsController < WorkflowController
  inherit_resources
  actions :new, :create
  defaults :resource_class => ReviewConductor
  belongs_to :article
  
  def new
    # Why doesn't this automatically take into account the resource_class?
    @review = resource_class.new
    new!
  end
  
  def create
    params[:review_conductor][:review_author_id] = current_user.id
    params[:review_conductor][:review_article_id] = params[:article_id]
    @review = resource_class.new params[:review_conductor]
    create! { workflow_article_path @article }
  end
end
