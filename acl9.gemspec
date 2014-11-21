# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "acl9/version"

Gem::Specification.new do |s|
  s.authors           = ["oleg dashevskii"]
  s.email             = ["olegdashevskii@gmail.com"]
  s.description       = %q{Role-based authorization system for Rails with a nice DSL for access control lists}
  s.summary           = %q{Yet another role-based authorization system for Rails}
  s.homepage          = "http://github.com/be9/acl9"

  s.files             = `git ls-files`.split($\)
  s.test_files        = s.files.grep(%r{^test/})
  s.name              = "acl9"
  s.require_paths     = ["lib"]
  s.version           = Acl9::VERSION
  s.license           = 'MIT'

  s.rdoc_options      = ["--charset=UTF-8"]

  s.add_dependency "rails",  "~> 4.0.0"

  s.add_development_dependency "RedCloth"
  s.add_development_dependency "yard"
  s.add_development_dependency 'sqlite3'
end

