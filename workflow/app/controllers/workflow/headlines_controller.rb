class Workflow::HeadlinesController < WorkflowController
  respond_to :html

  before_filter :require_user
  before_filter {current_user.can_edit_headlines!}

  def index
    respond_with :workflow, @headlines = Headline.order(:priority)
  end

  # GET: headlines/:article_id
  def show
    @article = Article.find params[:id]
    respond_with :workflow, @headline = Headline.new
  end

  def new
    respond_with :workflow, @headline = Headline.new
  end

  def edit
    respond_with :workflow, @headline = Headline.find(params[:id])
  end

  def create
    @article = Article.find params[:article_id]
    @headline = Headline.create(
      :priority => params[:headline][:priority],
      :article => @article
    )
    respond_with :workflow, @headline, :location => [:workflow, :headlines]
  end

  def update
    @headline = Headline.update params[:id], params[:headline]
    respond_with :workflow, @headline, :location => [:workflow, :headlines]
  end

  def destroy
    @headline = Headline.find(params[:id])
    # Not automatic because the association is backwards?
    @headline.article.headline = nil
    if @headline.article.save
      @headline.destroy
    end
    respond_with :workflow, @headline
  end
end
