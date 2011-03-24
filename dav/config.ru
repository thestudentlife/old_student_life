require 'active_record'
require 'active_support/core_ext/string/inflections'
require 'dav'
require 'incopy'

require 'sinatra/base'
require 'time'
require 'rack/utils'

class String
  def to_slug
    # http://stackoverflow.com/questions/1302022/best-way-to-generate-slugs-human-readable-ids-in-rails/1302183#1302183
    #strip the string
    ret = self.strip.downcase

    #blow away apostrophes
    ret.gsub! /['`]/,""

    # @ --> at, and & --> and
    ret.gsub! /\s*@\s*/, " at "
    ret.gsub! /\s*&\s*/, " and "

    #replace all non alphanumeric, underscore or periods with hyphen
     ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '-'  

     #convert double hyphens to single
     ret.gsub! /-+/,"-"

     #strip off leading/trailing hyphen
     ret.gsub! /\A[_\.]+|[_\.]+\z/,""

     ret
  end
end

module Dav
  module Propfind
    def propfind (path, opts={}, &b)
        route 'PROPFIND', path, opts, &b
    end
  end
  
  class App < Sinatra::Base
    class <<self
      include Propfind
    end
    
    helpers do
      def multistatus
        xml = Builder::XmlMarkup.new
        xml.instruct!
        xml.D :multistatus, "xmlns:D" => "DAV:" do
          yield xml
        end
        [207, xml.target!]
      end
    
      def dav_response (xml, opts={})
        opts.merge!(
          :ctime => Time.at(0),
          :mtime => Time.at(0),
          :mime => 'text/html',
          :size => 4.kilobytes
        )
        
        xml.D :response do
          xml.D :href, File.join(request.env['SCRIPT_NAME'], opts[:href])
          xml.D :propstat do
            xml.D :prop do
              xml.D :creationdate, opts[:ctime].httpdate
              xml.D :getlastmodified, opts[:mtime].httpdate
              xml.D :resourcetype do xml.D :collection if opts[:collection?] end
              xml.D :getcontenttype, opts[:mime]
              xml.D :getcontentlength, opts[:size]
              xml.D :supportedlock do end
            end
            xml.D :status, "HTTP/1.1 200 OK"
          end
        end
      end
    end
    
    # Routes
    
    before do
      request.path_info = Rack::Utils.unescape(request.path_info)
      request.script_name = Rack::Utils.unescape(request.script_name)
    end
    
    def issues_path
      '/A/issues/'
    end
    
    def issue_path_template
      File.join issues_path, '/:issue/'
    end
    def issue_path(issue)
      issues_path.sub(':issue', issue.davslug)
    end
    
    def issue_section_path_template
      File.join issue_path_template, '/:section/'
    end
    def issue_section_path(issue, section)
      File.join issue_path(issue), issue_section_path_template.sub(':section', section.url)
    end
    
    def article_path_template
      File.join issue_section_path_template, '/:article/'
    end
    def article_path(article)
      File.join issue_section_path(article.issue, article.section), article_path_template.sub(':article', article.davslug)
    end
    
    def article_authors_path(article)
      File.join article_path(article), '/Authors.txt'
    end
    
    propfind '/A/issues/:issue/:section/:article/' do
      @article = Article.find params[:article]
      multistatus do |xml|
        dav_response(xml,
          :href => "/A/issues/#{params[:issue]}/#{params[:section]}/#{params[:article]}/",
          :collection? => true)
        dav_response(xml,
          :href => "/A/issues/#{params[:issue]}/#{params[:section]}/#{params[:article]}/Authors.txt"
        )
      end
    end
    
    propfind '/A/issues/:issue/:section/' do
      @issue = Issue.find params[:issue]
      @section = Section.find_by_url params[:section]
      @articles = Article.where(:issue_id => @issue.id, :section_id => @section.id)
      multistatus do |xml|
        dav_response(xml,
          :href => "/A/issues/#{params[:issue]}/#{params[:section]}",
          :collection? => true)
        @articles.each do |article|
          dav_response(xml,
            :href => "/A/issues/#{params[:issue]}/#{params[:section]}/#{article.davslug}",
            :collection? => true)
        end
      end
    end
    
    propfind '/A/issues/:issue/' do
      @issue = Issue.find params[:issue]
      multistatus do |xml|
        dav_response(xml,
          :href => "/A/issues/#{params[:issue]}",
          :collection? => true)
        @issue.sections.each do |section|
          dav_response(xml,
            :href => "/A/issues/#{params[:issue]}/#{section.url}",
            :collection? => true)
        end
      end
    end
    
    propfind '/A/issues/' do
      multistatus do |xml|
        dav_response(xml,
          :href => '/A/issues',
          :collection? => true
        )
        Issue.all.each do |issue|
          dav_response(xml,
            :href => "/A/issues/#{issue.davslug}",
            :collection? => true
          )
        end
      end
    end
    
    propfind '/A/' do
      multistatus do |xml|
        dav_response(xml,
          :href => '/A',
          :collection? => true
        )
        dav_response(xml,
          :href => '/A/issues',
          :collection? => true
        )
      end
    end
    
    propfind '/' do
      multistatus do |xml|
        dav_response(xml,
          :href => '/',
          :collection? => true
        )
        dav_response(xml,
          :href => '/A',
          :collection? => true
        )
      end
    end
    
    options '/' do
      [
        200,
        {
          "Content-Type" => "text/html",
          "Dav" => "1",
          "MS-Author-Via" => "DAV",
          "Allow" => "OPTIONS,HEAD,GET,PROPFIND"
        },
        ''
      ]
    end
  end
end 

# models
def model(sym)
  autoload sym, File.dirname(__FILE__) + "/../lib/common/models/#{sym.to_s.underscore}.rb"
end
model :Issue
model :PrintPublishedArticle

module DavOld
  
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
        def size
          content.size
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
    params[:model].article.authors.map(&:to_s).join("\n")
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
    def size
      @model.file.size
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

  class IssueSectionArticlesCollection < WebDAV::AbstractCollection
    def initialize(path, issue, section)
      @issue = issue
      @section = section
      super path
    end
  
    def children
      #PrintPublishedArticle.
      #  group("article_id").
      #  joins(:article).
      #  where(:articles => {:issue_id => @model.id}).
      @issue.articles.
      where(:articles => {:section_id => @section.id}).
      map do |article|
        if article.print_published_articles.any?
          article.print_published_articles.per_article.first
        else
          Struct.new(:article, :revision, :title).new(
            article,
            article.revisions.latest.first,
            nil
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
  
  class IssueSectionsCollection < WebDAV::AbstractCollection
    def initialize(path, model)
      super path
      @model = model
    end
    def children
      Section.
        all.
        reject { |section| section.articles.where(:issue_id => @model.id).empty? }.
      map do |section|
        IssueSectionArticlesCollection.
        new(section.url, @model, section).
        tap { |child| child.added_to_collection(self) }
      end
    end
  end

  class IssueCollection < WebDAV::AbstractCollection 
    def children
      Issue.
        all.
      map do |issue|
        IssueSectionsCollection.
          new(issue.name.gsub(/\//,'_'), issue).
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

run Dav::App