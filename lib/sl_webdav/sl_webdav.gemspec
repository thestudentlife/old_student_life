# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sl_webdav"
  s.version = "0"

  s.authors = ["Michael Maltese"]
  s.email = "mike@mikemaltese.com"
  s.files = ["lib/**/*"]
  s.require_paths = ["lib"]
  s.summary = ""

  [
    'activesupport',
    'rack',
    'sinatra',
    'sl_workflow_data'
  ].
  map &s.method(:add_dependency)
end

