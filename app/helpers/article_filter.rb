require 'espresso'
class ArticleFilter < Espresso::ModelFilter
  self.model = Article
  filter :belongs_to, :model_name => :issue, :pretty_attribute => :name
  filter :belongs_to, :model_name => :section, :pretty_attribute => :name
end