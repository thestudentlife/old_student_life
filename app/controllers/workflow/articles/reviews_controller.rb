class Workflow::Articles::ReviewsController < WorkflowController
  inherit_resources
  actions :new, :create
  defaults :resource_class => ReviewConductor
  belongs_to :article
  
  def new
    # Why doesn't this automatically take into account the resource_class?
    new! {
      @review = resource_class.new @article
    }
  end
  
  def create
    params[:review_conductor][:review_author_id] = current_user.id
    params[:review_conductor][:title_author_id] = current_user.id
    @article = Article.find params[:article_id]
    @review = resource_class.new @article, params[:review_conductor]
    if @review.save
      redirect_to workflow_article_path(@article)
    else
      render :new
    end
  end
end
