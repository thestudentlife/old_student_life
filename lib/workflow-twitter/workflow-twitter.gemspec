# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "workflow-twitter"
  s.version     = '0.0.0'
  s.platform    = Gem::Platform::RUBY
  s.summary     = ""

  s.add_dependency("twitter")

  s.files         = Dir.glob("{lib}/**/*")
  s.require_paths = ["lib"]
end
