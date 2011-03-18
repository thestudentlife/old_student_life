class Headline < ActiveRecord::Base
  has_one :article
  validates :priority, :numericality => { :only_integer => true }
end
