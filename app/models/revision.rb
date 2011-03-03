class Revision < ActiveRecord::Base
  belongs_to :article
  validates_presence_of :body
  
  def to_s
    body
  end
end
