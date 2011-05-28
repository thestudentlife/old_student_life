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
    enforce_url view_context.article_path(@article)
    # This might fail. If it does, it shouldn't effect the render.
    # There's gotta be logging functionality around here somewhere..
    #ViewedArticle.new(:article => @article).save
  end
  
  def author
    @author = Author.find params[:author]
    enforce_url view_context.author_path(@author)
    
    @articles = Article.find_all_by_author(@author).order('published_at DESC')
  end
  
  def section
    @section = Section.find_by_url! params[:section]
    enforce_url view_context.section_path(@section)
    
    @articles = Article.find_all_published_in_section(@section)
  end
  
  def search
    @search = unless params[:q].blank?
      Article.search do
        keywords params[:q]
        with(:published, true)
        with(:published_at).less_than Time.now
      end.results
    else
      nil
    end
  end
end
