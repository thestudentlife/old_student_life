module ReverseMarkdown
  def self.html_to_markdown (text)
    text.
    gsub(/\n/,'').
    gsub(/<p>(.*?)<\/p>/) { "#$1\n\n" }.
    gsub(/<strong>(.*?)<\/strong>/) { "**#$1**" }.
    gsub(/<em>(.*?)<\/em>/) { "*#$1*" }.
    gsub(/\n{2,}/,"\n\n").
    strip
  end
end

class Workflow::Articles::RevisionsController < WorkflowController
  inherit_resources
  belongs_to :article
  before_filter :require_user
  
  def new
    new! do
      if @article.revisions.latest.any?
        @revision.body = ReverseMarkdown.html_to_markdown(@article.revisions.latest.first.body)
      end
    end
  end
  
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
