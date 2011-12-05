LoveTax3::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => 'tax.local' }
  Rails.application.routes.default_url_options[:host] = 'tax.local'

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :test
  end

end


# Omniauth / loveland app ids
APP_ID = 'lovetax'
APP_SECRET = 'vie402jv00v,53n2xxyBZ'
CUSTOM_PROVIDER_URL = 'http://home.local'

#Rails.application.config.middleware.use OmniAuth::Builder do
#  provider :josh_id, APP_ID, APP_SECRET
#end

