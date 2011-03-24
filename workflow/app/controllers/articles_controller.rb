class ArticlesController < ApplicationController
  
  layout "front"
  
  before_filter do @most_viewed = WebPublishedArticle.latest_most_viewed(10) end
  before_filter do @sections = Section.all end
  
  def index
    @featured_articles = WebPublishedArticle.featured
    #@articles = WebPublishedArticle.not_featured
    @news = Section.find_by_url('news')
    @articles = WebPublishedArticle.
      published.
      joins(:article).
      where(:articles => {:section_id => @news.id}).
      limit(5)
  end
  
  def article
    @article = WebPublishedArticle.published.find_by_article_id! params[:id]
    
    if request.fullpath != view_context.article_path(@article)
      redirect_to view_context.article_path(@article), :status => :moved_permanently
    end
    # This might fail. If it does, it shouldn't effect the render.
    # There's gotta be logging functionality around here somewhere..
    ViewedArticle.new(:article => @article.article).save
  end
  
  def author
    @author = Author.find params[:author]
    if request.fullpath != view_context.author_path(@author)
      redirect_to view_context.author_path(@author), :status => :moved_permanently
    end
    
    @articles = WebPublishedArticle.find_all_by_author @author
  end
  
  def section
    @section = Section.find_by_url! params[:section]
    
    @articles = WebPublishedArticle.find_all_by_section @section
  end
  
  def subsection
    @section = Section.find_by_url! params[:section]
    @subsection = @section.subsections.find_by_url! params[:subsection]
    
    @articles = WebPublishedArticle.find_all_by_subsection @subsection
    
    render :action => "section"
  end
end
