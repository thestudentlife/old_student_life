class ArticlesController < ApplicationController
  
  layout "front"
  
  before_filter do @most_viewed = ViewedArticle.latest_most_viewed(10) end
  before_filter do @sections = Section.all end
  
  def index
    @headlines = Revision.latest_headlines.includes(:article)
    @revisions = Revision.latest_published_not_in_headlines.includes(:article)
  end
  
  def article
    @section = Section.find_by_url! params[:section]
    if params[:subsection]
      @subsection = @section.subsections.find_by_url! params[:subsection]
    end
    
    if @subsection
      @article = @subsection.articles.find params[:id]
    else
      @article = @section.articles.find params[:id]
      raise ActiveRecord::RecordNotFound if @article.subsection
    end
    
    if request.fullpath != view_context.article_path(@article)
      redirect_to view_context.article_path(@article), :status => :moved_permanently
    end
    
    @revision = @article.latest_published_revision
    
    # This might fail. If it does, it shouldn't effect the render.
    # There's gotta be logging functionality around here somewhere..
    ViewedArticle.new(:article => @article).save
  end
  
  def author
    @author = Author.find params[:author]
    if request.fullpath != view_context.author_path(@author)
      redirect_to view_context.author_path(@author), :status => :moved_permanently
    end
    
    @revisions = @author.latest_published_revisions
  end
  
  def section
    @section = Section.find_by_url! params[:section]
    
    @revisions = @section.latest_published_revisions
  end
  
  def subsection
    @section = Section.find_by_url! params[:section]
    @subsection = @section.subsections.find_by_url! params[:subsection]
    
    @revisions = @subsection.latest_published_revisions
    
    render :action => "section"
  end
end
