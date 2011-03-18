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
  
  #validates_with ReviewValidator
  validates :article, :presence => true
  validates :review_slot,
    :presence => true,
    :not_in => {
      :collection => lambda { article.review_slots },
      :message => "Article already has a review for this slot"
    }
end
