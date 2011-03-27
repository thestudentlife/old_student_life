class Workflow::Articles::PrintPublishedArticlesController < WorkflowController
  inherit_resources
  actions :new, :create, :destroy
  belongs_to :article
  
  def create
    create! { workflow_article_path(@article) }
  end
  
  def destroy
    destroy! { workflow_article_path(@article) }
  end
  
end
