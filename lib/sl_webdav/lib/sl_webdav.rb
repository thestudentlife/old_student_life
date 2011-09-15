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
				"<#{@article.davslug}><body>#{body}</body></#{@article.davslug}>"
			end
			
			def body
				if @article.body
					@article.body.gsub("&nbsp;", " ").gsub(/\s+/,' ').gsub("</p>","</p>\n").gsub("&", "&amp;").
					gsub(/\s+class=".*?"/,'').gsub(/<\/?o:.*?>/,'').gsub(/\s+style=".*?"/,'').gsub(/<\/?span.*?>/,'').
					gsub(/<\/?font.*?>/,'').gsub(/<\/?xml.*?>/,'').gsub(/<\/?style.*?>/,'').gsub(/<br\/?>/, "\n").
					gsub("</div>", "</div>\n")
				else
					""
				end
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
						interpolate :article => "article.davslug_with_id"

						file ArticleXML do
							path ':file.indesign.xml'
							interpolate :file => "article.davslug_with_id"
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
