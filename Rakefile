#!/usr/bin/env rake
require 'bundler/setup'
require 'bundler/gem_tasks'

desc 'Default: run tests.'
task :default => :test

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
end

require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end

