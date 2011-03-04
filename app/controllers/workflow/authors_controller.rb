class Workflow::AuthorsController < ApplicationController
  
  before_filter :require_user, :find_article
  
  def new
    @authors = StaffMember.all
  end
  def create
    @author = StaffMember.find params[:author_id]
    
    if @article.authors.include? @author
      redirect_to new_workflow_article_author_path(@article), :notice => "Author already exists"
    elsif @article.authors << @author
      redirect_to workflow_article_path(@article), :notice => 'Author was successfully added'
    else
      redirect_to new_workflow_article_author_path(@article), :notice => 'Author was not added'
    end
  end
  def destroy
    @author = @article.authors.find params[:author_id]
    
    if @article.authors.delete @author
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