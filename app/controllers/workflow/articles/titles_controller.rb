class Workflow::Articles::TitlesController < WorkflowController
  inherit_resources
  actions :new, :create, :destroy
  defaults :resource_class => ArticleTitle
  belongs_to :article
  
  def create
    params[:article_title][:article] = @article
    params[:article_title][:author] = current_user
    create! { workflow_article_path(@article) }
  end
  
end
