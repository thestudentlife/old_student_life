class PhotoSet < ActiveRecord::Base
  belongs_to :article
  has_many :photos
end