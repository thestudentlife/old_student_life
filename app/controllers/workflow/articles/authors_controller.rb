class Workflow::Articles::AuthorsController < WorkflowController
  respond_to :html
  
  before_filter { @article = Article.find params[:article_id] }
  
  def new
    respond_with :workflow, @authors = Author.alphabetical
  end
  def create
    @author = Author.find params[:author_id]
    
    workflow_update = WorkflowUpdate.new_for_adding_author_to_article(@author, @article)
    workflow_update.author = current_user
      
    if @article.authors.include? @author
      redirect_to new_workflow_article_author_path(@article), :notice => "Author already exists"
    elsif @article.authors << @author
      # TODO: Transaction
      workflow_update.save
      redirect_to workflow_article_revisions_path(@article), :notice => 'Author was successfully added'
    else
      redirect_to new_workflow_article_author_path(@article), :notice => 'Author was not added'
    end
  end
  def destroy
    @author = @article.authors.find params[:id]
    
    workflow_update = WorkflowUpdate.new_for_removing_author_from_article(@author, @article)
    workflow_update.author = current_user
      
    @article.authors.delete @author
    # TODO: Transaction
    workflow_update.save
    respond_with :workflow, @author, :location => [:workflow, @article, :revisions]
  end
end
