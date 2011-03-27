# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "workflow-dav"
  s.version = "0.1.0"

  s.authors = ["Michael Maltese"]
  s.date = "2011-03-26"
  s.email = "mike@mikemaltese.com"
  s.files = ["lib/workflow/dav.rb"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.7"
  s.summary = "Create simple read-only WebDAV servers with Rack"

  s.add_dependency('activesupport')
  s.add_dependency('builder')
  s.add_dependency('incopy')
  s.add_dependency('rack')
  s.add_dependency('sinatra')

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
  end
end

