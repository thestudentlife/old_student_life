require 'daffy'
require 'sinatra/base'

module SL
	module WebDAV
		class ArticleXML
			def initialize(context)
				@article = context.article
			end

			def get; xml; end
			def mime; "text/xml"; end
			def size; xml.size; end
			def mtime; @article.updated_at; end
			
			def xml
				"<articles><#{@article.davslug}><body>#{@article.body}</body></#{@article.davslug}></articles>"
			end
		end
		
		Root = Daffy::Root.new
		Root.config do
			collection "Issue.scoped" do
				path ':issue'
				find :find
				interpolate :issue => "issue.davslug"

				collection "Section.scoped" do
					path ':section'
					find :find_by_url!
					interpolate :section => "section.url"

					collection "Article.includes(:workflow).where(:issue_id => issue.id, :section_id => section.id)" do
						path ':article' 
						find :find
						interpolate :article => "article.davslug"

						file ArticleXML do
							path ':file.indesign.xml'
							interpolate :file => "article.davslug"
						end
					end
				end
			end
		end
		
		class App < Sinatra::Base
			error ActiveRecord::RecordNotFound do
				response.status = 404
			end
			set :raise_errors, true
			set :show_exceptions, false
			
			route 'PROPFIND', /((^)|(\/))\./ do
				throw(:halt, [404, "Not found\n"])
			end
			
			get "/test" do
				"{\n" +
				"  request.script_name: \"" + request.script_name + "\"\n" +
				"  request.path_info: \"" + request.path_info + "\"\n" +
				"}\n"
			end
			
			include Daffy::Sinatra
			daffy Root
		end
	end
end
