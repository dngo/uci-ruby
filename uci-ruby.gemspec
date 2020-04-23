# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'uci/version'

Gem::Specification.new do |s|
  s.name = "uci-ruby"
  s.version = Uci::VERSION
  s.authors = ["David Ngo"]
  s.email = ["davngo@gmail.com"]

  s.summary = "Ruby client for the uci chess engines"
  s.description = "Ruby client for uci chess engines"
  s.license = "MIT"

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(spec)/})

  s.add_development_dependency "rspec"
  s.add_development_dependency "byebug"
end
