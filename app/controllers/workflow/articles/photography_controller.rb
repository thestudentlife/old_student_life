class Workflow::Articles::PhotographyController < WorkflowController
	before_filter { @article = Article.find params[:article_id] }

	def edit
	end
end