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
  
  module NamedRoutes
    
    def self.included(base)
      base.class_eval do
        class <<self
          include Helpers
        end
        helpers(Helpers)
      end
    end
    
    module Helpers
      def issues_path
        '/A/issues/'
      end
    
      def issue_path_template
        File.join issues_path, '/:issue/'
      end
      def issue_path(issue)
        File.join(issues_path, issue.davslug)
      end
    
      def issue_section_path_template
        File.join issue_path_template, '/:section/'
      end
      def issue_section_path(issue, section)
        File.join issue_path(issue), section.url
      end
    
      def article_path_template
        File.join issue_section_path_template, '/:article/'
      end
      def article_path(article)
        File.join(
          issue_section_path(article.issue, article.section),
          article.davslug
        )
      end
    
      def article_authors_path_template
        File.join article_path_template, 'Authors.txt'
      end
      def article_authors_path(article)
        File.join article_path(article), 'Authors.txt'
      end
      
      def article_incopy_path_template
        File.join article_path_template, 'Body.incx'
      end
      def article_incopy_path(article)
        File.join article_path(article), 'Body.incx'
      end
      
      def article_headline_path_template
        File.join article_path_template, 'Headline.txt'
      end
      def article_headline_path(article)
        File.join article_path(article), 'Headline.txt'
      end
      
      def article_not_published_path_template
        File.join article_path_template, 'NOT PUBLISHED.txt'
      end
      def article_not_published_path(article)
        File.join article_path(article), 'NOT PUBLISHED.txt'
      end
      
      def article_image_path_template
        File.join article_path_template, 'Image.:ext'
      end
      def article_image_path(article)
        image = article.images.first
        ext = File.extname(image.file.url.sub(/\?.*$/,''))
        File.join article_path(article), "Image#{ext}"
      end
      
      def article_image_caption_path_template
        File.join article_path_template, 'ImageCaption.txt'
      end
      def article_image_caption_path(article)
        File.join article_path(article), 'ImageCaption.txt'
      end
      
      def article_image_credit_path_template
        File.join article_path_template, 'ImageCredit.txt'
      end
      def article_image_credit_path(article)
        File.join article_path(article), 'ImageCredit.txt'
      end
    end
  end
  
  class App < Sinatra::Base
    class <<self
      include Propfind
    end
    include NamedRoutes
    
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
    
    propfind article_path_template do
      @article = Article.find params[:article]
      multistatus do |xml|
        dav_response(xml,
          :href => article_path(@article),
          :collection? => true)
        dav_response(xml,
          :href => article_authors_path(@article),
          :mime => 'text/plain'
        )
        dav_response(xml,
          :href => article_incopy_path(@article),
          :mime => 'application/x-incx'
        )
        if @article.published_in_print?
          dav_response(xml,
            :href => article_headline_path(@article),
            :mime => 'text/plain'
          )
        else
          dav_response(xml,
            :href => article_not_published_path(@article),
            :mime => 'text/plain'
          )
        end
        if @article.images.any?
          image = @article.images.first
          mime = Rack::Mime.mime_type File.extname(image.file.url.sub(/\?.*/,''))
          dav_response(xml,
            :href => article_image_path(@article),
            :mime => mime
          )
          dav_response(xml,
            :href => article_image_credit_path(@article),
            :mime => 'text/plain'
          )
          dav_response(xml,
            :href => article_image_caption_path(@article),
            :mime => 'text/plain'
          )
        end
      end
    end
    
    propfind issue_section_path_template do
      @issue = Issue.find params[:issue]
      @section = Section.find_by_url params[:section]
      @articles = Article.where(:issue_id => @issue.id, :section_id => @section.id)
      multistatus do |xml|
        dav_response(xml,
          :href => issue_section_path(@issue, @section),
          :collection? => true)
        @articles.each do |article|
          dav_response(xml,
            :href => article_path(article),
            :collection? => true)
        end
      end
    end
    
    propfind issue_path_template do
      @issue = Issue.find params[:issue]
      multistatus do |xml|
        dav_response(xml,
          :href => issue_path(@issue),
          :collection? => true)
        @issue.sections.each do |section|
          dav_response(xml,
            :href => issue_section_path(@issue, section),
            :collection? => true)
        end
      end
    end
    
    propfind issues_path do
      multistatus do |xml|
        dav_response(xml,
          :href => issues_path,
          :collection? => true
        )
        Issue.all.each do |issue|
          dav_response(xml,
            :href => issue_path(issue),
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
          :href => issues_path,
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