class Workflow::AuthorsController < WorkflowController
  respond_to :html
  
  def index
    @authors = Author.all
    respond_with(:workflow, @authors)
  end

  def show
    @author = Author.find(params[:id])
    respond_with(:workflow, @author)
  end

  def new
    @author = Author.new
    respond_with(:workflow, @author)
  end

  def edit
    @author = Author.find(params[:id])
    respond_with(:workflow, @author)
  end

  def create
    @author = Author.new(params[:author])
    flash[:notice] = "Author was successfully created" if @author.save
    respond_with(:workflow, @author, :location => [:workflow, :authors])
  end

  def update
    @author = Author.find(params[:id])
    flash[:notice] = "Author was successfully updated" if @author.update_attributes(params[:author])
    respond_with(:workflow, @author, :location => [:workflow, :authors])
  end

  def destroy
    @author = Author.find(params[:id])
    @author.destroy
    flash[:notice] = "Successfully destroyed author"
    respond_with(:workflow, @author)
  end
end
