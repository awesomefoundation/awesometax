LoveTax3::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  puts "I'm in staging config"

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => 'stage.lovetax.us' }
  
  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :test
  end

  config.middleware.use ExceptionNotifier,
    :email_prefix => "[LoveTax staging] ",
    :sender_address => %{"Exception Notifier" <info@makeloveland.com>},
    :exception_recipients => %w{larry@makeloveland.com}

  Paperclip.options[:command_path] = "/usr/bin"
end

# Omniauth / loveland app ids
#APP_ID = 'lovetax'
#APP_SECRET = 'vie402jv00v,53n2xxyBZ'
#CUSTOM_PROVIDER_URL = 'http://stage.makeloveland.com'

#Rails.application.config.middleware.use OmniAuth::Builder do
#  provider :josh_id, APP_ID, APP_SECRET
#end

