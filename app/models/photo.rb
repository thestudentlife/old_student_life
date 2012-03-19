class Photo < ActiveRecord::Base
  has_attached_file :file,
    :path => ":rails_root/public/uploads/photos/:id:style.:extension",
    :url => "/uploads/photos/:id:style.:extension",
    :styles => {
      :small => ["150x150>", :jpg]
    }
  belongs_to :photo_set
end