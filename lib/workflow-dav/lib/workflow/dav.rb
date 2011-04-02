require 'active_support/core_ext/string/inflections'
require 'workflow/incopy'

require 'builder'
require 'sinatra/base'
require 'time'
require 'rack/utils'

require 'active_record/errors'

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

module Workflow
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
          '/A/issues'
        end
    
        def issue_path_template
          File.join issues_path, '/:issue'
        end
        def issue_path(issue)
          File.join(issues_path, issue.davslug)
        end
    
        def issue_section_path_template
          File.join issue_path_template, '/:section'
        end
        def issue_section_path(issue, section)
          File.join issue_path(issue), section.url
        end
    
        def article_path_template
          File.join issue_section_path_template, '/:article'
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
          File.join article_path_template, 'Headlines.txt'
        end
        def article_headline_path(article)
          File.join article_path(article), 'Headlines.txt'
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
        
        def article_lockfile_path_template
          File.join article_path_template, ':lock.idlk'
        end
        def article_lockfile_path(article)
          File.join article_path(article), "#{InCopyArticle.for_article(article).lockfile}.idlk"
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
    
        def dav_status (xml, href, status)
          xml.D :response do
            xml.D :href, File.join(request.env['SCRIPT_NAME'], href)
            xml.D :propstat do
              xml.D :prop do
                xml.D :"current-user-privilege-set" do
                  xml.D(:privilege) { xml.D :read }
                  xml.D(:privilege) { xml.D :write }
                end
              end
              xml.D :status, "HTTP/1.1 404 Not Found"
            end
          end
        end
    
        def dav_lock (token)
          xml = Builder::XmlMarkup.new
          xml.instruct!
          xml.D :prop, "xmlns:D" => "DAV:" do
           xml.D :lockdiscovery do
             xml.D :activelock do
               xml.D(:locktype) { xml.D :write }
               xml.D(:lockscope) { xml.D :exclusive }
               xml.D :depth, 0
               xml.D :timeout, 'Second-604800'
               xml.D(:locktoken) { xml.D :href, token }
             end
           end
          end
          [
            200,
            {"Lock-Token" => token},
            xml.target!
          ]
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
                xml.D :"current-user-privilege-set" do
                  xml.D(:privilege) { xml.D :read }
                  xml.D(:privilege) { xml.D :write }
                end
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
        
        params[:user] = User.find_by_email env['REMOTE_USER']
      end
    
      set :raise_errors, false
      set :show_exceptions, false
      set :dump_errors, false
      error ActiveRecord::RecordNotFound do
        response.status = 404
      end
    
      get article_lockfile_path_template do
        @article = Article.find params[:article]
        @incopy = InCopyArticle.for_article(@article)
        if @article.locked? and not @incopy.lockfile.blank?
          @incopy.lockfile_content || ''
        else
          response.status = 404
        end
      end
      put article_lockfile_path_template do
        @article = Article.find params[:article]
        if @article.locked?
          return response.status = 423 # Locked
        else
          @article.lock params[:user]
          @article.save!
          incopy = InCopyArticle.for_article(@article)
          incopy.lockfile = params[:lock]
          incopy.lockfile_content = request.body.read
          incopy.save!
          response.status = 201 # Created
        end
      end
      route 'LOCK', article_lockfile_path_template do
        @article = Article.find params[:article]
        token = "opaquelocktoken:" + Rack::Utils.escape(article_lockfile_path(@article)) + Time.now.to_i.to_s
        dav_lock(token)
      end
      route 'UNLOCK', article_lockfile_path_template do
        response.status = 204 # No Content
      end
      propfind article_lockfile_path_template do
        @article = Article.find params[:article]
        if @article.locked? and not InCopyArticle.for_article(@article).lockfile.blank?
          multistatus do |xml|
            dav_response(xml,
              :href => article_lockfile_path(@article),
              :mime => 'application/x-idlk'
            )
          end
        else
          response.status = 404
        end
      end
      delete article_lockfile_path_template do
        @article = Article.find params[:article]
        @article.unlock
        @article.save!
        incopy = InCopyArticle.for_article(@article)
        incopy.lockfile = nil
        incopy.save!
        
        response.status = 204 # Action enacted, empty response
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
        InCopyArticle.for_article(@article).to_incopy
      end
      put article_incopy_path_template do
        # Allow if user has it locked
        @article = Article.find params[:article]
        if @article.locked_by == params[:user]
          @incopy = InCopyArticle.for_article(@article)
          @incopy.parse(request.body.read).tap do |rev|
            rev.author = params[:user]
            rev.save!
          end
          @incopy.save!
          puts @incopy.header
        else
          response.status = 423 # Locked
        end
      end
      route 'LOCK', article_incopy_path_template do
        @article = Article.find params[:article]
        # Allow if user has it locked
        if @article.locked_by == params[:user]
          token = Rack::Utils.escape(article_incopy_path(@article)) + Time.now.to_i.to_s 
          dav_lock(token)
        else
          response.status = 423 # Locked
        end
      end
      route 'UNLOCK', article_incopy_path_template do
        response.status = 204 # No content
      end
      propfind article_incopy_path_template do
        @article = Article.find params[:article]
        puts request.body.read
        multistatus do |xml|
          dav_response(xml,
            :href => article_incopy_path(@article),
            :mime => 'application/x-incx'
          )
        end
      end
    
      get article_headline_path_template do
        @article = Article.find params[:article]
        @article.titles.map(&:to_s).join("\n")
      end
      propfind article_headline_path_template do
        @article = Article.find params[:article]
        multistatus do |xml|
          dav_response(xml,
            :href => article_headline_path(@article),
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
          dav_response(xml,
            :href => article_headline_path(@article),
            :mime => 'text/plain'
          )
          if @article.locked? and not InCopyArticle.for_article(@article).lockfile.blank?
            dav_response(xml,
              :href => article_lockfile_path(@article),
              :mime => 'application/x-idlk'
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
        @section = Section.find_by_url! params[:section]
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
        raise NotFound unless @issue
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
    
      propfind '/A' do
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
            "Dav" => "1,2",
            "MS-Author-Via" => "DAV",
            "Allow" => "OPTIONS,HEAD,GET,PROPFIND,DELETE,PUT,LOCK"
          },
          ''
        ]
      end
      
      route 'LOCK', // do
        response.status = 423 # Locked
      end

      use Rack::Auth::Basic, "WebDAV" do |username, password|
        user = User.find_by_email(username)
        user.valid_password? password if user
      end
    end
  end
end
