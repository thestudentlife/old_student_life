class Image < ActiveRecord::Base
  has_attached_file :file,
    :path => ":rails_root/public/uploads/article_images/:id:style.:extension",
    :url => "/uploads/article_images/:id:style.:extension",
    :styles => {
      :thumb => "75x75#",
      :small => "150x150>"
    }
  belongs_to :article
end
