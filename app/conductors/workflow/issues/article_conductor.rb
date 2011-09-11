class Workflow::Issues::ArticleConductor < Workflow::Conductor
  def initialize(opts={})
    @article = Article.new
    @article.section_id = opts[:section_id]
    @article.issue_id = opts[:issue_id]
    @workflow = @article.workflow
    @workflow.name = opts[:name]
  end
  
  def id
    @article.id
  end
  
  def name
    @workflow.name
  end
  
  def section_id
    @article.section_id
  end
  
  def save
    if valid?
      transact do
        @workflow.save!
        @article.save!
      end
    else
      false
    end
  end
  
  validate do
    add_errors @article
    add_errors @workflow
  end
end
