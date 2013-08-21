ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  Bundler.require(:test)
  require 'mocha/setup'
 end

class ActionController::TestCase
  include Devise::TestHelpers
end