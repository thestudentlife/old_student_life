class Workflow::ImagesController < ApplicationController
  
  before_filter :require_user, :find_article
  before_filter {current_staff_member.can_edit_article! @article}

  def index
    @images = @article.images
  end

  def show
    @image = @article.images.find params[:id]
  end

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
      redirect_to workflow_article_image_path(@article, @image), :notice => 'Image was successfully created.'
    else
      render :action => "new"
    end
  end

  def update
    @image = Image.find(params[:id])

    if @image.update_attributes(params[:image])
      redirect_to workflow_article_image_path(@article, @image), :notice => 'Image was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy

    redirect_to workflow_article_images_url(@article)
  end
  
  private
  def find_article
    @article = Article.find params[:article_id]
  end
end
