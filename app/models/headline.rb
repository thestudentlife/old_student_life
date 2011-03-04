class Headline < ActiveRecord::Base
  has_one :article
  validates_presence_of :article
end
