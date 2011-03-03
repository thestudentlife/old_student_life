class AuthorsController < ApplicationController
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
