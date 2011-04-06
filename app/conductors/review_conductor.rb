class ReviewConductor < Workflow::Conductor
  def initialize(article, opts={})
    @article = article
    @review = WorkflowReview.new(
      :author_id => opts[:review_author_id],
      :comment => opts[:review_comment],
      :review_slot_id => opts[:review_review_slot_id],
      :article_id => @article.id
    )
    @author = Author.find opts[:author_id] if opts[:author_id]
    @title = ArticleTitle.new(
      :text => opts[:title_text],
      :article_id => @article.id,
      :author_id => opts[:title_author_id]
    )
    @author.articles << article if @author
  end
  
  def title_text
    @title.text
  end
  
  def review_comment
    @review.comment
  end
  
  def persisted?
    false
  end
  
  def to_key
    nil
  end
  
  def save
    valid? ? transact do
      @review.save!
      @title.save!
      @author.save! if needs_author?
    end : false
  end
  
  def needs_author?
    @_needs_author ||= @article.authors.none?
  end
  
  def authors
    @_authors ||= Author.all
  end
  
  validate do
    add_errors(@review)
    add_errors(@title)
    if needs_author? and @author.nil?
      errors.add :author, 'needs to be added to this article'
    end
  end
end