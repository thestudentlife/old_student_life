class ReviewConductor < Workflow::Conductor
  conducts :review => WorkflowReview
  
  def self.model_name
    @_model_name = ActiveModel::Name.new(WorkflowReview)
  end
  
  def persisted?
    false
  end
  
  def to_key
    nil
  end
  
  def save
    transact do
      review.save!
    end
  end
  
  def needs_author?
    false
  end
  
  validate do
    # @review.article.author
    add_errors(@review)
  end
end