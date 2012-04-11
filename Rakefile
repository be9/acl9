#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rake'
require 'rake/testtask'
require 'yard'

desc 'Default: run tests.'
task :default => :test

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end
