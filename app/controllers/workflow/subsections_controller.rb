class Workflow::SubsectionsController < WorkflowController
  respond_to :html

  before_filter :require_user
  before_filter { @section = Section.find params[:section_id] }
  before_filter {current_user.can_edit_sections!}

  def new
    respond_with :workflow, @subsection = Subsection.new
  end

  def edit
    respond_with :workflow, @subsection = @section.subsections.find(params[:id])
  end

  def create
    respond_with :workflow,
      @subsection = @section.subsections.create(params[:subsection]),
      :location => [:workflow, :sections]
  end

  def update
    respond_with :workflow,
      @subsection = @section.subsections.update(params[:id], params[:subsection]),
      :location => [:workflow, :sections]
  end

  def destroy
    @subsection = @section.subsections.find params[:id]
    
    if @subsection.articles.empty?
      @subsection.destroy
      flash[:notice] = 'Subsubsection was successfully destroyed'
    else
      flash[:warning] = "Can't delete subsection with articles"
    end
    redirect_to [:workflow, :sections]
  end
end
