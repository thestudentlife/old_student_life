class PhotoSetPresenter
  def self.find(id)
    article = Article.find id
    new :article => article, :photo_set => article.photo_set
  end
  def self.update(id, params)
    article = Article.find id
    photo_set = article.photo_set
    photo_set.update_attributes params
    photo_set.save
    new :article => article, :photo_set => article.photo_set
  end
  def initialize(opts={})
    @article = opts[:article]
    @photo_set = opts[:photo_set]
  end
  def model
    @photo_set
  end
  
  delegate :title, :to_param, :to => :@article
  delegate :description, :photos, :to => :@photo_set
end