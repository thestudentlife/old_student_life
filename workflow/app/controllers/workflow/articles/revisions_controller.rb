class Workflow::Articles::RevisionsController < WorkflowController
  inherit_resources
  belongs_to :article
  before_filter :require_user
  
  def create
    params[:revision] ||= {}
    params[:revision].merge!(
      :body => params["wmd-input"],
      :article => @article,
      :author => current_user
    )
    create! { [:workflow, @article] }
  end
end
