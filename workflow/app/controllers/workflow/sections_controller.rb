class Workflow::SectionsController < WorkflowController
  respond_to :html

  before_filter :require_user
  before_filter {current_user.can_edit_sections!}

  def index
    respond_with :workflow, @sections = Section.all
  end

  def new
    respond_with :workflow, @section = Section.new
  end

  def edit
    respond_with :workflow, @section = Section.find(params[:id])
  end

  def create
    @section = Section.create(params[:section])
    respond_with :workflow, @section, :location => [:workflow, :sections]
  end

  def update
    @section = Section.update(params[:id], params[:section])
    respond_with :workflow, @section, :location => [:workflow, :sections]
  end

  def destroy
    @section = Section.find(params[:id])
    if @section.articles.empty?
      @section.destroy
      flash[:notice] = 'Section was successfully destroyed'
    else
      flash[:warning] = "Can't delete section with articles"
    end
    redirect_to(workflow_sections_url)
  end
end
