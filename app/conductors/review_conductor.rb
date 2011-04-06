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
    @title = opts[:title_text].try(:strip) || ''
    @author.articles << article if @author
    @article.titles << @title
  end
  
  def title_text
    @title
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
      @author.save! if needs_author?
      @article.save!
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
    add_errors(@article)
    if needs_author?
      if @author.nil?
        errors.add :author, 'needs to be added to this article'
      else
        add_errors(@author)
      end
    end
  end
end