class WorkflowUpdate < ActiveRecord::Base
  belongs_to :article
  belongs_to :author, :class_name => "User"

  serialize :updates, Hash
  
  def self.new_for_article_params (article, params)
    workflow_update = WorkflowUpdate.new :article => article, :updates => {}
    
    if article.workflow.status_message.to_s != params[:status_message].to_s
      workflow_update.updates["Status message"] = [article.workflow.status_message, params[:status_message]]
    end
    
    return workflow_update
  end
  
  def self.new_for_adding_author_to_article (author, article)
    return WorkflowUpdate.new(
      :article => article,
      :updates => {author.to_s => 'was added to authors'}
    )
  end
  def self.new_for_removing_author_from_article (author, article)
    return WorkflowUpdate.new(
      :article => article,
      :updates => {author.to_s => 'was removed from authors'}
    )
  end
end
