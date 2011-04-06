class Workflow::Articles::TitlesController < WorkflowController
  respond_to :html

  def new
    @title = TitleConductor.new
    respond_with @title
  end
  
  def create
    params[:title_conductor] ||= {}
    params[:title_conductor][:article_id] = params[:article_id]
    @title = TitleConductor.create params[:title_conductor]
    respond_with @title, :location => workflow_article_path(params[:article_id])
  end
  
end
