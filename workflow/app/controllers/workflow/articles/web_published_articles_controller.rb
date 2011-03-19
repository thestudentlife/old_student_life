class Workflow::Articles::WebPublishedArticlesController < WorkflowController
  inherit_resources
  actions :new, :create
  belongs_to :article
  
  def create
    create! { workflow_article_path(@article) }
  end
  
end
