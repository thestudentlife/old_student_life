# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sl_data"
  s.version = "0.0.0"

  s.authors = ["Michael Maltese"]
  s.email = ["mike@mikemaltese.com"]
  s.files = Dir["lib/**/*", "app/**/*"]
  s.require_paths = ["lib"]
  s.summary = ""

  %w{activerecord rails paperclip}.map &s.method(:add_dependency)
end

