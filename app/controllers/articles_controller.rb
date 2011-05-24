class ArticlesController < ApplicationController
  
  layout "front"
  
  before_filter do @most_viewed = Article.latest_most_viewed(10) end
  before_filter do @sections = Section.all end
  
  def index
    @featured_articles = Article.featured
    @news = Section.order('priority ASC').first
    @articles = Article.find_all_published_in_section(@news).limit(5)
  end
  
  def article
    @article = Article.published.find_by_id! params[:id]
    
    if request.fullpath != view_context.article_path(@article)
      redirect_to view_context.article_path(@article), :status => :moved_permanently
    end
    # This might fail. If it does, it shouldn't effect the render.
    # There's gotta be logging functionality around here somewhere..
    #ViewedArticle.new(:article => @article).save
  end
  
  def author
    @author = Author.find params[:author]
    if request.fullpath != view_context.author_path(@author)
      redirect_to view_context.author_path(@author), :status => :moved_permanently
    end
    
    @articles = Article.find_all_by_author(@author).order('published_at DESC')
  end
  
  def section
    @section = Section.find_by_url! params[:section]
    
    if request.fullpath != view_context.section_path(@section)
      redirect_to view_context.section_path(@section), :status => :moved_permanently
    end
    
    @articles = Article.find_all_published_in_section(@section)
  end
  
  def search
    @search = unless params[:q].blank?
      Article.search(:include => [:web_published_article]) do
        keywords params[:q]
        without(:published_at, nil)
      end.results.map &:web_published_article
    else
      nil
    end
  end
end
