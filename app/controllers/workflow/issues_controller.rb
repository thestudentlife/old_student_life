class Workflow::IssuesController < WorkflowController
  inherit_resources
  
  def show
    super do
      @articles_by_section = {}
      Section.all.each do |section|
        @articles_by_section[section] = @issue.articles.
        includes(:reviews => [:author]).
        includes(:revisions).
        includes(:authors).
        includes(:web_published_article).
        where(:section_id => section.id).
        sort_by { |a| a.workflow.name }
      end
      
    end
  end
end