class Workflow::IssuesController < WorkflowController
  inherit_resources
  
  def show
    super do
      @articles_by_section = {}
      Section.all.each do |section|
        @articles_by_section[section] = @issue.articles.where(:section_id => section.id).sort_by(&:name)
      end
      
    end
  end
end