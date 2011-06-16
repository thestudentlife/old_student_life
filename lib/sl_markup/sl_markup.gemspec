# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sl_markup"
  s.version = "0"

  s.authors = ["Michael Maltese"]
  s.email = "mike@mikemaltese.com"
  s.files = Dir["lib/**/*"]
  s.require_paths = ["lib"]
  s.summary = ""
  
  ['nokogiri'].
  map &s.method(:add_dependency)

end

