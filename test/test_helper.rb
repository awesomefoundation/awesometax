ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  require 'mocha'
  Bundler.require(:test)
  include Devise::TestHelpers 
 end
