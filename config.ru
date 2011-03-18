map '/' do
	app, options = Rack::Builder.parse_file(File.dirname(__FILE__) + '/workflow/config.ru')
	run app
end
