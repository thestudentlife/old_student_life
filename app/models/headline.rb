class Headline < ActiveRecord::Base
  has_one :article
  validates :article, :presence => true, :uniqueness => true
  validates :priority, :numericality => { :only_integer => true }
end
