class Workflow::Issues::ArticlesController < WorkflowController
  respond_to :html
  
  before_filter { @issue = Issue.find params[:issue_id] }
  def new
    @sections = Section.all
    respond_with :workflow, @issue, @article = Workflow::Issues::ArticleConductor.new
  end
  def create
    @article = Workflow::Issues::ArticleConductor.new(params[:article].merge :issue => @issue)
    if @article.save
      # TODO: Probably works, can't test right now because database is messed up
      # and I can't access the production server to make a clone
      redirect_to workflow_article_path(:id => @article.id)
    else
      @sections = Section.all
      render :new
    end
  end

end