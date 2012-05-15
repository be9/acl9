ENV['RAILS_ENV'] = 'test'

require File.expand_path( '../dummy/config/environment.rb', __FILE__)
require 'active_support'
require 'active_record'
require 'test/unit'
require 'shoulda'
require 'factory_girl'
require 'factories'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
#Dir['#{File.dirname(__FILE__)}/support/**/*.rb'].each { |f| require f }
