require 'active_record'
require 'active_support/core_ext/string/inflections'
require 'dav'
require 'incopy'

# models
def model(sym)
  autoload sym, File.dirname(__FILE__) + "/../lib/common/models/#{sym.to_s.underscore}.rb"
end
model :Issue
model :PrintPublishedArticle

module Dav
  
  class <<self
    def DynamicResource(mime, &b)
      klass = Class.new WebDAV::DataResource
      klass.class_eval do
        class <<self
          attr_accessor :mime
          attr_accessor :b
        end
        @@mime = nil
        @@b = nil
        
        attr_accessor :params
        def initialize (name, params={})
          super name
          @params = params
        end
        def mimetype
          self.class.mime
        end
        def content
          instance_eval &(self.class.b)
        end
      end
      klass.mime = mime
      klass.b = b
      klass
    end
  end
  
  InCopyResource = DynamicResource('application/x-incx') do
    InCopy.html_to_incopy params[:model].revision.body
  end
  
  HeadlineResource = DynamicResource('text/plain') do
    params[:model].title.text
  end
  
  NotPublishedResource = DynamicResource('text/plain') {""}
  
  AuthorsResource = DynamicResource('text/plain') do
    params[:model].article.authors.map(&:to_s).join('\n')
  end
  
  class ImageResource < WebDAV::Resource
    def initialize (name, params)
      @model = params[:model]
      super name
    end
    def get(env)
      resp = Rack::Response.new
      resp.redirect(@model.file.url)
      resp.finish
    end
    def mimetype
      Rack::Mime.mime_type File.extname(@model.file.url.sub(/\?.*/,''))
    end
  end

  ImageCaptionResource = DynamicResource('text/plain') do
    params[:model].caption
  end
  
  ImageCreditResource = DynamicResource('text/plain') do
    params[:model].credit
  end
  
  class ArticleFilesCollection < WebDAV::AbstractCollection
    def initialize(article, name)
      super name
      @model = article
      @files = {
        'Body.incx' => InCopyResource,
        'Authors.txt' => AuthorsResource
      }
      if @model.title # Published
        @files.merge!('Headline.txt' => HeadlineResource)
      else # Not published yet
        @files.merge!('NOT PUBLISHED.txt' => NotPublishedResource)
      end
      @files.merge!(@files) { |key, value| value.new(key, :model => @model) }
      
      if @model.article.images.any?
        @image = @model.article.images.first
        image_files = {
          image_path => ImageResource,
          'ImageCaption.txt' => ImageCaptionResource,
          'ImageCredit.txt' => ImageCreditResource
        }
        image_files.merge!(image_files) { |key, value| value.new(key, :model => @image) }
        @files.merge! image_files
      end
      
      @files.values.each do |child|
        child.added_to_collection(self)
      end
    end
  
    def image_path
      'Image' + File.extname(@image.file.url.sub(/\?.*$/,''))
    end
  
    def children
      @files.values
    end
    
    def find_child(name)
      @files[name]
    end
    
  end

  class IssueArticlesCollection < WebDAV::AbstractCollection
    def initialize(issue, name)
      @model = issue
      super name
    end
  
    def children
      #PrintPublishedArticle.
      #  group("article_id").
      #  joins(:article).
      #  where(:articles => {:issue_id => @model.id}).
      @model.articles.
      map do |article|
        if article.web_published_articles.any?
          article.web_published_articles.published.first
        else
          WebPublishedArticle.new(
            :article => article,
            :revision => article.revisions.latest.first
          )
        end
      end.
      map do |article|
        ArticleFilesCollection.
          new(article, article.article.name).
          tap { |child| child.added_to_collection(self) }
      end
    end
  end

  class IssueCollection < WebDAV::AbstractCollection 
    def children
      Issue.
        all.
      map do |issue|
        IssueArticlesCollection.
          new(issue, issue.name.gsub(/\//,'_').gsub(/\s+/,'_')).
          tap { |child| child.added_to_collection(self) }
      end
    end
  end

  class App < WebDAV::Server
    def initialize
      issues = IssueCollection.new 'issues'

      a = WebDAV::Collection.new 'A'
      a << issues

      root = WebDAV::Collection.new '/'
      root << a
      
      super root
    end
  end
end

run Dav::App.new
