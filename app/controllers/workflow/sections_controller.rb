class Workflow::SectionsController < WorkflowController

  before_filter :require_user
  before_filter {current_staff_member.can_edit_sections!}

  def index
    @sections = Section.all
  end

  def new
    @section = Section.new
  end

  def edit
    @section = Section.find(params[:id])
  end

  def create
    @section = Section.new(params[:section])

   if @section.save
      redirect_to(workflow_sections_path, :notice => 'Section was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @section = Section.find(params[:id])

    if @section.update_attributes(params[:section])
      redirect_to(workflow_sections_path, :notice => 'Section was successfully updated.')
    else
      render :action => "edit"
    end
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
