class Workflow::RevisionsController < ApplicationController

  before_filter :require_user, :find_article
  before_filter {current_staff_member.can_post_to_article! @article}

  # GET /revisions/new
  def new
    @revision = Revision.new
  end

  # GET /revisions/1/edit
  def edit
    @revision = @article.revisions.find(params[:id])
  end

  # POST /revisions
  def create
    params[:revision][:body] = params["wmd-input"]
    @revision = Revision.new(params[:revision])
    @revision.article = @article
    @revision.author = current_user.staff_member
    @revision.visible_to_article_author = @article.open_to_author
    
    if @revision.save
      redirect_to workflow_article_path(@article), :notice => 'Revision was successfully created.'
    else
      render :action => "new"
    end
  end

  # PUT /revisions/1
  # PUT /revisions/1.xml
  def update
    @revision = Revision.find(params[:id])

      if @revision.update_attributes(params[:revision])
        redirect_to workflow_article_path(@revision.article_id), :notice => 'Revision was successfully updated.'
      else
        render :action => "edit"
      end
  end
  
  private
  def find_article
    @article = Article.find params[:article_id]
  end
end
