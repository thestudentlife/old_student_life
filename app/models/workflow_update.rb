class WorkflowUpdate < ActiveRecord::Base
  belongs_to :article
  belongs_to :author, :class_name => "StaffMember"

  serialize :updates, Hash
  
  def self.new_for_article_params (article, params)
    workflow_update = WorkflowUpdate.new :article => article, :updates => {}
    workflow_update.visible_to_article_author = (article.open_to_author or article.workflow_status.open_to_author)
    
    if article.status_message.to_s != params[:status_message].to_
      workflow_update.updates["Status message"] = [article.status_message, params[:status_message]]
    end
    if article.workflow_status_id != params[:workflow_status_id].to_i
      workflow_status = WorkflowStatus.find params[:workflow_status_id]
      workflow_update.updates["Workflow status"] = [article.workflow_status.to_s, workflow_status.to_s]
    end
    if params[:subsection_id] and not params[:subsection_id].empty? and article.subsection_id != params[:subsection_id].to_i
      new_subsection = Subsection.find(params[:subsection_id]).to_s
      old_subsection = (a = article.subsection) ? a.to_s : "(none)"
      workflow_update.updates["Subsection"] = [old_subsection, new_subsection]
    end
    bool_open_to_author = params[:open_to_author] == '0' ? false : true
    if article.open_to_author != bool_open_to_author
      workflow_update.updates["Open to author (override)"] = [article.open_to_author, bool_open_to_author]
    end
    bool_publishable = params[:publishable] == '0' ? false : true
    if article.publishable != bool_publishable
      workflow_update.updates["Publishable (override)"] = [article.publishable, bool_publishable]
    end
    
    return workflow_update
  end
  
  def self.new_for_adding_author_to_article (author, article)
    return WorkflowUpdate.new(
      :article => article,
      :updates => {author.to_s => 'was added to authors'},
      :visible_to_article_author => (article.open_to_author or article.workflow_status.open_to_author))
  end
  def self.new_for_removing_author_from_article (author, article)
    return WorkflowUpdate.new(
      :article => article,
      :updates => {author.to_s => 'was removed from authors'},
      :visible_to_article_author => (article.open_to_author or article.workflow_status.open_to_author))
  end
end
