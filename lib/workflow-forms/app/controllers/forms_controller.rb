class FormsController < ApplicationController
	layout 'front'
	
	def show
	  @sections = Section.all
		@form = Forms::Form.find params[:id]
	end
end
