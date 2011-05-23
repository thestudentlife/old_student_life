class Workflow::Issues::ArticlesController < WorkflowController
  respond_to :html
  
  before_filter { @issue = Issue.find params[:issue_id] }
  def new
    @sections = Section.all
    respond_with :workflow, @issue, @article = Article.new
  end
  def create
    @article = Article.create(params[:article].merge :issue => @issue)
    respond_with :workflow, @issue, @article,
      :location => [:workflow, @article]
  end

end