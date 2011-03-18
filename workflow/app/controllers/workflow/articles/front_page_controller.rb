class Workflow::Articles::FrontPageController < WorkflowController
  inherit_resources
  defaults :resource_class => FrontPageArticle, :instance_name => 'front_page_article'
  actions :new, :create
  
  before_filter { @article = Article.find params[:article_id] }
  
  def new
    @front_page_article = FrontPageArticle.new :article => @article
    new!
  end
  
  def create
    @front_page_article = FrontPageArticle.new(
      :article => @article,
      :priority => params[:front_page_article][:priority]
    )
    create! { workflow_article_path(@article) }
  end
  
end
