class Workflow::SubsectionsController < WorkflowController

  before_filter :require_user
  before_filter { @section = Section.find params[:section_id] }
  before_filter {current_staff_member.can_edit_sections!}

  def new
    @subsection = Subsection.new
  end

  def edit
    @subsection = @section.subsections.find params[:id]
  end

  def create
    @subsection = @section.subsections.build params[:subsection]

   if @subsection.save
      redirect_to(workflow_sections_path, :notice => 'Subsubsection was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @subsection = @section.subsections.find params[:id]

    if @subsection.update_attributes(params[:subsection])
      redirect_to(workflow_sections_path, :notice => 'Subsubsection was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @subsection = @section.subsections.find params[:id]
    
    if @subsection.articles.empty?
      @subsection.destroy
      flash[:notice] = 'Subsubsection was successfully destroyed'
    else
      flash[:notice] = "Can't delete subsection with articles"
    end
    redirect_to(workflow_sections_path)
  end
end
