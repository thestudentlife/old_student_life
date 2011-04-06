class TitleConductor < Workflow::Conductor
  def initialize(opts={})
    @article = Article.find opts[:article_id] if opts[:article_id]
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
    valid? ? transact do
      @article.titles << @title
      @article.save!
    end : false
  end
  
  validates :title, :presence => true
  validate do
    errors.add :article, 'couldn\'t be found' if @article.nil?
    errors.add :title, 'already exists' if @article.titles.include? title
  end
end