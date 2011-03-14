class Workflow::AuthorsController < WorkflowController
  respond_to :html
  responders :flash
  
  def index
    respond_with :workflow, @authors = Author.all
  end

  def show
    respond_with :workflow, @author = Author.find(params[:id])
  end

  def new
    respond_with :workflow, @author = Author.new
  end

  def edit
    respond_with :workflow, @author = Author.find(params[:id])
  end

  def create
    @author = Author.create(params[:author])
    respond_with(:workflow, @author, :location => [:workflow, :authors])
  end

  def update
    @author = Author.update(params[:id], params[:author])
    respond_with(:workflow, @author, :location => [:workflow, :authors])
  end

  def destroy
    respond_with :workflow, @author = Author.destroy(params[:id])
  end
end
