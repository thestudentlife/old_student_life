# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sl_workflow_data"
  s.version = "0"

  s.authors = ["Michael Maltese"]
  s.email = ["mike@mikemaltese.com"]
  s.files = Dir["lib/**/*", "app/**/*"]
  s.require_paths = ["lib"]
  s.summary = ""

  [
    'sl_data',
    'sl_markup',
    'activerecord',
    'htmldiff',
    'htmlentities',
    'rails',
  ].
  map &s.method(:add_dependency)
end

