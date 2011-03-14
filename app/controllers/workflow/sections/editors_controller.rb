class Workflow::Sections::EditorsController < WorkflowController
  respond_to :html
  
  before_filter :require_user
  before_filter { current_user.can_edit_sections! }
  before_filter { @section = Section.find params[:section_id]}
  
  def new
    respond_with :workflow, @editors = User.all
  end
  def create
    @editor = User.find params[:editor_id]
    
    if @section.editors.include? @editor
      render :new, :notice => "Editor already exists"
    elsif @section.editors << @editor
      redirect_to [:workflow, :sections], :notice => 'Editor was successfully added'
    else
      render :new, :notice => 'Editor was not added'
    end
  end
  def destroy
    @section.editors.delete(@section.editors.find params[:id])
    respond_with :workflow, @section, :location => [:workflow, :sections]
  end
end
