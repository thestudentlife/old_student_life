require 'espresso'
class Workflow::PhotoSetsController < WorkflowController
  respond_to :html
  
  def index
    @model = PhotoSetAdmin.new
    @filter = ArticleFilter.new(params)
    @collection = Espresso::Paginator.paginate(params, @filter.collection)
    respond_with @collection
  end
  
  def show
    @photo_set = PhotoSetPresenter.find params[:id]
    respond_with @photo_set
  end
  
  def edit
    @photo_set = PhotoSetPresenter.find(params[:id]).model
    respond_with @photo_set
  end
  
  def update
    @photo_set = PhotoSetPresenter.update(params[:id], params[:photo_set]).model
    respond_with @photo_set, :location => "/workflow/photo_sets/#{params[:id]}"
  end
end
