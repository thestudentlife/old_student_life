require 'active_record'
require 'active_support/core_ext/string/inflections'
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
    
    get article_authors_path_template do
      @article = Article.find params[:article]
      @article.authors.map(&:to_s).to_sentence
    end
    propfind article_authors_path_template do
      @article = Article.find params[:article]
      multistatus do |xml|
        dav_response(xml,
          :href => article_authors_path(@article),
          :mime => 'text/plain'
        )
      end
    end
    
    get article_incopy_path_template do
      @article = Article.find params[:article]
      if @article.published_in_print?
        @revision = @article.print_published_articles.order('created_at DESC').first.revision
      else
        @revision = @article.revisions.latest.first
      end
      InCopy.html_to_incopy @revision.body
    end
    propfind article_incopy_path_template do
      @article = Article.find params[:article]
      multistatus do |xml|
        dav_response(xml,
          :href => article_incopy_path(@article),
          :mime => 'application/x-incx'
        )
      end
    end
    
    get article_headline_path_template do
      @article = Article.find params[:article]
      return [404, {}, ''] unless @article.published_in_print?
      @article.print_published_articles.order('created_at DESC').first.title.text
    end
    propfind article_headline_path_template do
      @article = Article.find params[:article]
      return [404, {}, ''] unless @article.published_in_print?
      multistatus do |xml|
        dav_response(xml,
          :href => article_headline_path(@article),
          :mime => 'text/plain'
        )
      end
    end
    
    get article_not_published_path_template do
      @article = Article.find params[:article]
      return [404, {}, ''] if @article.published_in_print?
      ''
    end
    propfind article_not_published_path_template do
      @article = Article.find params[:article]
      return [404, {}, ''] if @article.published_in_print?
      multistatus do |xml|
        dav_response(xml,
          :href => article_not_published_path(@article),
          :mime => 'text/plain'
        )
      end
    end
    
    get article_image_path_template do
      @article = Article.find params[:article]
      @image = @article.images.first
      Rack::Response.new.tap do |resp|
        resp.redirect(@image.file.url)
      end.finish
    end
    propfind article_image_path_template do
      @article = Article.find params[:article]
      @image = @article.images.first
      mime = Rack::Mime.mime_type File.extname(@image.file.url.sub(/\?.*/,''))
      dav_response(xml,
        :href => article_image_path(@article),
        :mime => mime
      )
    end
    
    get article_image_credit_path_template do
      @article = Article.find params[:article]
      @image = @article.images.first
      @image.credit
    end
    propfind article_image_credit_path_template do
      @article = Article.find params[:article]
      @image = @article.images.first
      multistatus do |xml|
        dav_response(xml,
          :href => article_image_credit_path(@article),
          :mime => 'text/plain'
        )
      end
    end
    
    get article_image_caption_path_template do
      @article = Article.find params[:article]
      @image = @article.images.first
      @image.caption
    end
    propfind article_image_caption_path_template do
      @article = Article.find params[:article]
      @image = @article.images.first
      multistatus do |xml|
        dav_response(xml,
          :href => article_image_caption_path(@article),
          :mime => 'text/plain'
        )
      end
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

run Dav::App