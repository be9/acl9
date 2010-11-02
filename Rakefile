require 'rubygems'
require 'rake'
require 'rake/testtask'

desc 'Default: run tests.'
task :default => :test

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "acl9"
    s.summary = "Yet another role-based authorization system for Rails"
    s.email = "olegdashevskii@gmail.com"
    s.homepage = "http://github.com/be9/acl9"
    s.description = "Role-based authorization system for Rails with a nice DSL for access control lists"
    s.authors = ["oleg dashevskii"]
    s.files = FileList["[A-Z]*", "{lib,test}/**/*.rb"]
    s.add_development_dependency "be9-context", ">= 0.5.5"
    s.add_development_dependency "jnunemaker-matchy", ">= 0.4.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false
end

begin
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb']
    #t.options = ['--any', '--extra', '--opts'] # optional
  end
rescue LoadError
end
