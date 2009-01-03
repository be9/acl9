require 'rubygems'
require File.join(File.dirname(__FILE__), 'lib', 'acl9', 'version')
require 'rake'
require 'spec/rake/spectask'

desc 'Default: run specs.'
task :default => :spec

begin
  require 'echoe'

  Echoe.new 'acl9' do |p|
    p.version = Acl9::Version::STRING
    p.author = "Oleg Dashevskii"
    p.email  = 'olegdashevskii@gmail.com'
    p.project = 'acl9'
    p.summary = "Yet another role-based authorization system for Rails with a nice DSL for access control lists."
    p.url = "http://github.com/be9/acl9"
    p.ignore_pattern = ["spec/db/*.sqlite3", "spec/debug.log"]
    p.development_dependencies = ["rspec >=1.1.11", "rspec-rails >=1.1.11"]
  end
rescue LoadError => boom
  puts "You are missing a dependency required for meta-operations on this gem."
  puts "#{boom.to_s.capitalize}."
end

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Regenerate the .gemspec'
task :gemspec => :package do
  gemspec = Dir["pkg/**/*.gemspec"].first
  FileUtils.cp gemspec, "."
end
