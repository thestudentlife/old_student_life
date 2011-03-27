class NotInValidator < ActiveModel::EachValidator
  def validate_each (record, attribute, value)
    if record.instance_eval(&options[:collection]).include? value
      record.errors[attribute] << options[:message]
    end
  end
end

class WorkflowReview < ActiveRecord::Base
  belongs_to :article
  belongs_to :review_slot
  belongs_to :author, :class_name => 'User'
  
  #validates_with ReviewValidator
  validates :article, :presence => true
  validates :review_slot, :presence => true
  validates :author, :presence => true
  
  validates :review_slot_id,
    :not_in => {
      :collection => lambda { article.reviews.reject { |review| review.id == id }.map { |review| review.review_slot_id } },
      :message => "Article already has a review for that slot!"
    }
end
