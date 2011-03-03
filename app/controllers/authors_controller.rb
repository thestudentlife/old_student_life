class AuthorsController < ApplicationController
  def new
    @article = Article.find params[:article_id]
    @authors = StaffMember.all
  end
  def create
    @article = Article.find params[:article_id]
    @author = StaffMember.find params[:author_id]
    
    if @article.authors << @author
      redirect_to @article, :notice => 'Author was successfully added'
    else
      redirect_to new_article_author_path(@article), :notice => 'Author was not added'
    end
  end
  def destroy
    @article = Article.find params[:article_id]
    @author = @article.authors.find params[:author_id]
    
    if @article.authors.delete @author
      redirect_to @article, :notice => 'Author was successfully removed'
    else
      redirect_to @article, :notice => 'Author was not removed'
    end
  end
end
