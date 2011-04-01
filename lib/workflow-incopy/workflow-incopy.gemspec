# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "workflow-incopy"
  s.version = "0.1.0"

  s.authors = ["Michael Maltese"]
  s.date = "2011-03-31"
  s.email = "mike@mikemaltese.com"
  s.files = ["lib/workflow/incopy.rb"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.7"
  
  s.add_dependency('nokogiri')

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
  end
end

