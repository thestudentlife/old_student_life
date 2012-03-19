require 'builder'

class Daffy
	
	class ArticlePhotoFile
		def initialize(photo)
			@photo = photo
		end
		def mime; @photo.file.content_type; end
		def link
			@photo.file.url
		end
		def name
			@photo.id.to_s + "-" + @photo.file.original_filename.to_slug
		end
	end
	
	class ArticlePhotoSetDirectory
		def initialize(article)
			@photo_set = article.photo_set
		end
		def all
			@photo_set.photos.map &ArticlePhotoFile.method(:new)
		end
		def get(child)
			ArticlePhotoFile.new @photo_set.photos.find(child)
		end
		def name; "photos"; end
	end
	
	class ArticleInDesignFile
		def initialize(article)
			@article = article
		end
		def mime; "text/xml"; end
		def size; xml.size; end
		def mtime; @article.updated_at; end
		def get; xml; end
		def xml
			"<#{@article.davslug}><body>#{body}</body></#{@article.davslug}>"
		end
		def body
			if @article.body
				@article.body.gsub("&nbsp;", " ").gsub(/\s+/,' ').gsub("</p>","</p>\n").gsub("&amp;", "&").
				gsub("&", "&amp;"). gsub(/\s+class=".*?"/,'').gsub(/<\/?o:.*?>/,'').gsub(/\s+style=".*?"/,'').
				gsub(/<\/?span.*?>/,'').gsub(/<\/?font.*?>/,'').gsub(/<\/?xml.*?>/,'').gsub(/<\/?style.*?>/,'').
				gsub(/<br\/?>/, "\n").gsub("</div>", "</div>\n")
			else
				""
			end
		end
		def name
			@article.davslug_with_id + ".indesign.xml"
		end
	end

	class ArticleDirectory
		def initialize(article)
			@article = article
		end
		def all
			[ ArticleInDesignFile.new(@article), ArticlePhotoSetDirectory.new(@article) ]
		end
		def get(child)
			all.find { |c| c.name == child }
		end
		def name
			@article.davslug_with_id
		end
	end

	class IssueSectionDirectory
		def initialize(issue, section)
			@issue = issue
			@section = section
		end
		def all
			Article.where(:issue_id => @issue.id, :section_id => @section.id).map &ArticleDirectory.method(:new)
		end
		def get(child)
			ArticleDirectory.new Article.find child
		end
		def name
			@section.url
		end
	end

	class IssueDirectory
		def initialize(issue)
			@issue = issue
		end
		def all
			Section.all.map do |s| IssueSectionDirectory.new(@issue, s) end
		end
		def get(child)
			IssueSectionDirectory.new @issue, Section.find_by_url(child)
		end
		def name
			@issue.davslug
		end
	end

	class RootDirectory
		def all
			Issue.all.map &IssueDirectory.method(:new)
		end
		def get(child)
			IssueDirectory.new Issue.find(child)
		end
	end
	
	def self.multistatus
		xml = Builder::XmlMarkup.new :indent=>2
		xml.instruct!
		xml.D :multistatus, "xmlns:D" => "DAV:" do
			yield xml
		end
		[207, {"Content-Type" => "text/xml"}, [xml.target!]]
	end

	def self.dav_response (xml, opts={})
		opts = {
			:ctime => Time.at(0),
			:mtime => Time.at(0),
			:mime => 'text/plain',
			:size => 4096
		}.merge(opts)

		xml.D :response do
			xml.D :href, opts[:path]
			xml.D :propstat do
				xml.D :prop do
					xml.D :creationdate, opts[:ctime].httpdate
					xml.D :getlastmodified, opts[:mtime].httpdate
					xml.D :resourcetype do xml.D :collection if opts[:collection?] end
					xml.D :getcontenttype, opts[:mime]
					xml.D :getcontentlength, opts[:size]
				end
				xml.D :status, "HTTP/1.1 200 OK"
			end
		end
	end
	
	def self.dav_opts(node)
		opts = {}
		opts[:collection?] = node.respond_to?(:all)
		opts[:mime] = node.mime if node.respond_to?(:mime)
		opts[:mtime] = node.mtime if node.respond_to?(:mtime)
		opts[:size] = node.size if node.respond_to?(:size)
		opts
	end
	
	def self.call(env)
		req = Rack::Request.new(env)
		
		case req.request_method
		when /(PROPFIND)|(GET)/
			return [404, {"Content-Type" => "text/plain"}, []] if req.path_info.split("/").last =~ /^\./
			
			path_components = req.path_info.split("/")
			path_components.shift # "/"
			node = path_components.reduce(RootDirectory.new) { |last, c| last.get(c) }
			case req.request_method
			when "PROPFIND"
				multistatus do |xml|
					dav_response(xml, {:path => req.path}.merge(dav_opts node))
					node.all.each do |child|
						dav_response(xml, {:path => File.join(req.path, child.name)}.merge(dav_opts child))
					end if node.respond_to?(:all)
				end
			when "GET"
				if node.respond_to?(:link)
					[302, {"Content-Type" => node.mime, "Location" => node.link}, []]
				else
					[200, {"Content-Type" => node.mime, "Content-Length" => node.size.to_s}, [node.get]]
				end
			end
		when /(PUT)|(DELETE)|(MKCOL)|(LOCK)|(UNLOCK)/
			[405, {"Content-Type" => "text/plain"}, []]
		when "OPTIONS"
			[
				200,
				{
					"Content-Type" => "text/html",
					"Dav" => "1,2",
					"MS-Author-Via" => "DAV",
					"Allow" => "OPTIONS,HEAD,GET,PROPFIND"
				},
				[]
			]
		else
			[501, {"Content-Type" => "text/plain"}, []]
		end
	end
end