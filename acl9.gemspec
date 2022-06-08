# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "acl9/version"

Gem::Specification.new do |s|
  s.authors           = ["oleg dashevskii", "Jason King"]
  s.email             = ["olegdashevskii@gmail.com", "jk@handle.it"]
  s.description       = "Role-based authorization system for Rails with a concise DSL for securing your Rails application. Acl9 makes it easy to get security right for your app, the access control code sits right in your controller, the syntax is very easy to understand, and acl9 makes it easy to test your access rules."
  s.summary           = "Role-based authorization system for Rails with a concise DSL for securing your Rails application."
  s.homepage          = "http://github.com/be9/acl9"

  s.files             = `git ls-files`.split($\)
  s.test_files        = s.files.grep(%r{^test/})
  s.name              = "acl9"
  s.require_paths     = ["lib"]
  s.version           = Acl9::VERSION
  s.license           = 'MIT'

  s.required_ruby_version = ">= 2"

  s.rdoc_options      = ["--charset=UTF-8"]

  s.add_dependency "rails", '>= 5.0', '< 8.0'

  s.add_development_dependency "yard"
  s.add_development_dependency 'sqlite3'
end
