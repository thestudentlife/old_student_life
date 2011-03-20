require 'rubygems'

# Stolen from Rails3
# Set up gems listed in the Gemfile.
gemfile = File.expand_path('../Gemfile', __FILE__)
begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)

map '/webdav' do
  app, options = Rack::Builder.parse_file(File.dirname(__FILE__) + '/dav/config.ru')
  run app
end

map '/' do
	app, options = Rack::Builder.parse_file(File.dirname(__FILE__) + '/workflow/config.ru')
	run app
end
