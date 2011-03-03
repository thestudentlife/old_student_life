class RevisionsController < ApplicationController
  # GET /revisions/new
  def new
    @article = Article.find(params[:article_id])
    @revision = Revision.new
  end

  # GET /revisions/1/edit
  def edit
    @article = Article.find(params[:article_id])
    @revision = @article.revisions.find(params[:id])
  end

  # POST /revisions
  def create
    params[:revision][:article_id] = params[:article_id]
    params[:revision][:author_id] = current_user.staff_member.id
    @revision = Revision.new(params[:revision])
    
    if @revision.save
      redirect_to("/articles/#{params[:article_id]}", :notice => 'Revision was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /revisions/1
  # PUT /revisions/1.xml
  def update
    @revision = Revision.find(params[:id])

    respond_to do |format|
      if @revision.update_attributes(params[:revision])
        format.html { redirect_to(article_path(@revision.article_id), :notice => 'Revision was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @revision.errors, :status => :unprocessable_entity }
      end
    end
  end
end
