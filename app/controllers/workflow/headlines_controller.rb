class Workflow::HeadlinesController < WorkflowController

  before_filter :require_user
  before_filter {current_staff_member.can_edit_headlines!}

  def index
    @headlines = Headline.order(:priority)
  end

  # GET: articles/:id/headline
  def show
    @article = Article.find params[:id]
    @headline = Headline.new
  end

  def new
    @headline = Headline.new
  end

  def edit
    @headline = Headline.find(params[:id])
  end

  def create
    @article = Article.find params[:article_id]
    
    begin
      ActiveRecord::Base.transaction do
        @headline = Headline.create!(
          :priority => params[:headline][:priority],
          :article => @article
        )
      end
    rescue => e
      throw e
      render :action => "new"
    else
      redirect_to(workflow_headlines_path, :notice => 'Headline was successfully created.')
    end
  end

  def update
    @headline = Headline.find(params[:id])

    if @headline.update_attributes(params[:headline])
      redirect_to(workflow_headlines_path, :notice => 'Headline was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @headline = Headline.find(params[:id])
    # Not automatic because the association is backwards?
    @headline.article.headline = nil
    if @headline.article.save
      @headline.destroy
      flash[:notice] = 'Headline was successfully destroyed'
      redirect_to(workflow_headlines_url)
    end
  end
end
