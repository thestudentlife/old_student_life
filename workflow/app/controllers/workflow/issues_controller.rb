class Workflow::IssuesController < WorkflowController
  inherit_resources
  
  def show
    super { @articles = @issue.articles }
  end
end