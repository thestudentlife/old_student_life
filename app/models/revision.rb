class Revision < ActiveRecord::Base
  belongs_to :article
  validates_presence_of :text
  
  def to_s
    text
  end
end
