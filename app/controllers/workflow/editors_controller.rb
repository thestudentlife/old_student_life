class Workflow::EditorsController < ApplicationController
  
  before_filter :require_user, :find_section
  
  def new
    @editors = StaffMember.all
  end
  def create
    @editor = StaffMember.find params[:editor_id]
    
    if @section.editors.include? @editor
      redirect_to new_workflow_section_editor_path(@section), :notice => "Editor already exists"
    elsif @section.editors << @editor
      redirect_to workflow_sections_path, :notice => 'Editor was successfully added'
    else
      redirect_to new_workflow_section_editor_path(@section), :notice => 'Editor was not added'
    end
  end
  def destroy
    @editor = @section.editors.find params[:editor_id]
    
    if @section.editors.delete @editor
      redirect_to workflow_sections_path, :notice => 'Editor was successfully removed'
    else
      redirect_to workflow_sections_path, :notice => 'Editor was not removed'
    end
  end
  
  private
  def find_section
    @section = Section.find params[:section_id]
  end
end
