class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
  def new
    @article = Article.new
    @workflow_statuses = WorkflowStatus.all
    @sections = Section.all
  end
  def create
    @article = Article.new params[:article]
    
    if @article.save
      redirect_to @article, :notice => "Article was successfully created"
    else
      render :action => "new"
    end
  end
  def show
    @article = Article.find params[:id]
  end
  def edit
    @article = Article.find params[:id]
    @workflow_statuses = WorkflowStatus.all
    @sections = Section.all
  end
  def update
    @article = Article.find params[:id]
    if @article.update_attributes params[:article]
      redirect_to @article, :notice => "Article was successfully updated"
    else
      render :action => "edit"
    end
  end
end