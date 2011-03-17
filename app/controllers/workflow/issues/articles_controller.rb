class Workflow::Issues::ArticlesController < WorkflowController
  respond_to :html
  
  before_filter { @issue = Issue.find params[:issue_id] }
  def new
    @workflow_statuses = current_user.available_workflow_statuses
    @sections = Section.all
    @subsections = Subsection.all
    respond_with :workflow, @issue, @article = Article.new
  end
  def create
    @article = Article.create(params[:article].merge :issue => @issue)
    respond_with :workflow, @issue, @article,
      :location => [:workflow, @article]
  end

end