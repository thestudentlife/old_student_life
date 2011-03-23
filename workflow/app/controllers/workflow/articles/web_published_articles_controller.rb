class Workflow::Articles::WebPublishedArticlesController < WorkflowController
  inherit_resources
  actions :new, :create
  belongs_to :article
  
  def new
    new! do
      @web_published_article.published_at = Time.now - 7.hours
    end
  end
  
  def create
    create! { workflow_article_path(@article) }
  end
  
end
