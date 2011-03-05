class Workflow::AuthorsController < WorkflowController
  
  before_filter :require_user, :find_article
  before_filter {current_staff_member.can_edit_article! @article}
  
  def new
    @authors = StaffMember.all
  end
  def create
    @author = StaffMember.find params[:author_id]
    
    workflow_update = WorkflowUpdate.new_for_adding_author_to_article (@author, @article)
    workflow_update.author = current_staff_member
      
    if @article.authors.include? @author
      redirect_to new_workflow_article_author_path(@article), :notice => "Author already exists"
    elsif @article.authors << @author
      # TODO: Transaction
      workflow_update.save
      redirect_to workflow_article_path(@article), :notice => 'Author was successfully added'
    else
      redirect_to new_workflow_article_author_path(@article), :notice => 'Author was not added'
    end
  end
  def destroy
    @author = @article.authors.find params[:author_id]
    
    workflow_update = WorkflowUpdate.new_for_removing_author_from_article (@author, @article)
    workflow_update.author = current_staff_member
      
    if @article.authors.delete @author
      # TODO: Transaction
      workflow_update.save
      redirect_to workflow_article_path(@article), :notice => 'Author was successfully removed'
    else
      redirect_to workflow_article_path(@article), :notice => 'Author was not removed'
    end
  end
  
  private
  def find_article
    @article = Article.find params[:article_id]
  end
end
