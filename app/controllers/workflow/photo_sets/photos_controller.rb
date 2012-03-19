class Workflow::PhotoSets::PhotosController < WorkflowController
  respond_to :html
  before_filter do
    @photo_set = PhotoSetPresenter.find(params[:photo_set_id]).model
  end
  def new
    respond_with @photo = Photo.new
  end
  def create
    @photo = Photo.create(params[:photo].merge :photo_set => @photo_set)
    respond_with @photo, :location => "/workflow/photo_sets/#{params[:photo_set_id]}"
  end
  def edit
    respond_with @photo = @photo_set.photos.find(params[:id])
  end
  def update
    @photo = Photo.update(params[:photo].merge :photo_set => @photo_set)
    respond_with @photo, :location => "/workflow/photo_sets/#{params[:photo_set_id]}"
  end
  def destroy
    @photo = Photo.destroy params[:id]
    respond_with @photo, :location => "/workflow/photo_sets/#{params[:photo_set_id]}"
  end
end