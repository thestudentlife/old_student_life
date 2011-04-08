class Workflow::Articles::ImagesController < WorkflowController
  
  before_filter :require_user
  before_filter { @article = Article.find params[:article_id] }

  def new
    @image = Image.new
  end

  def edit
    @image = @article.images.find params[:id]
  end

  def create
    @image = Image.new(params[:image])
    @image.article = @article

    if @image.save
      redirect_to workflow_article_revisions_path(@article), :notice => 'Image was successfully created.'
    else
      render :action => "new"
    end
  end

  def update
    @image = Image.find(params[:id])

    if @image.update_attributes(params[:image])
      redirect_to workflow_article_revisions_path(@article), :notice => 'Image was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy

    redirect_to workflow_article_revisions_path(@article)
  end
end
