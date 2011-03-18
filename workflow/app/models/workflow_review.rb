class ReviewValidator < ActiveModel::Validator
  def validate(review)
    if review.article.review_slots.include? review.review_slot
      review.errors[:review_slot] << "Article already has a review for this slot"
    end
  end
end

class WorkflowReview < ActiveRecord::Base
  belongs_to :article
  belongs_to :review_slot
  
  validates_with ReviewValidator
  validates :article, :presence => true
  validates :review_slot, :presence => true
end
