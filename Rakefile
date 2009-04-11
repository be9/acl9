require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

desc 'Default: run specs.'
task :default => :spec

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "acl9"
    s.summary = "Yet another role-based authorization system for Rails with a nice DSL for access control lists."
    s.email = "olegdashevskii@gmail.com"
    s.homepage = "http://github.com/be9/acl9"
    s.description = "Yet another role-based authorization system for Rails with a nice DSL for access control lists."
    s.authors = ["oleg dashevskii"]
    s.files = FileList["[A-Z]*", "{lib,spec}/**/*.rb"]
    s.add_development_dependency "rspec", ">= 1.1.12"
    s.add_development_dependency "rspec-rails", ">= 1.1.12"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false
end
