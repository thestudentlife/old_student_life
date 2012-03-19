require 'ostruct'
class ArticleAdmin
  def columns
    [
      OpenStruct.new(:value => lambda { |a| a.title.blank? ? a.workflow.try(:name) : a.title }, :name => "Title", :sort => :title),
      OpenStruct.new(:value => :created_at.to_proc, :name => "Created At", :sort => :created_at),
      OpenStruct.new(:value => lambda { |a| a.issue.try(:name) }, :name => "Issue", :sort => :issue_id)
    ]
  end
  def actions
    []
  end
end