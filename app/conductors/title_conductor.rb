class TitleConductor < Workflow::Conductor
  def initialize(opts={})
    @article = Article.find opts[:article_id] if opts[:article_id]
    @workflow = @article.try(:workflow)
    @title = opts[:title].try(:strip) || ''
  end
  
  attr_accessor :title
  
  def persisted?
    false
  end
  
  def to_key
    nil
  end
  
  def save
    if valid?
      @workflow.proposed_titles << @title
      @workflow.save!
    else
      return false
    end
  end
  
  validates :title, :presence => true
  validate do
    errors.add :article, 'couldn\'t be found' if @article.nil?
    errors.add :title, 'already exists' if @workflow.proposed_titles.include? title
  end
end