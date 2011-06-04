class InCopyArticle < ActiveRecord::Base
  belongs_to :article
  
  validates :article, :presence => true
  
  def self.for_article(article)
    where(:article_id => article.id).first || new(:article => article)
  end
  
  def to_incopy
    revision = article.revisions.latest.first
    Markup::InCopy.markup_to_incopy revision.body, :header => header
  end
  
  def parse(incopy)
    self.header = Markup::InCopy.extract_headers incopy
    Revision.new(
      :article => article,
      :body => Markup::InCopy.incopy_to_markup(incopy)
    )
  end
  
  def ctime
    revision = article.revisions.latest.first
    revision.created_at
  end
  
  def mtime
    revision = article.revisions.latest.first
    revision.updated_at
  end
  
  def lockfile_ctime
    updated_at
  end
  def lockfile_mtime
    updated_at
  end
end
