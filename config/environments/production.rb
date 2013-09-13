LoveTax3::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

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
  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true
  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.default_url_options = { :host => 'awesometax-test.herokuapp.com' }
  Rails.application.routes.default_url_options[:host] = 'awesometax.awesomestudies.org'

  # ActionMailer::Base.smtp_settings = {
  #   :address        => 'smtp.sendgrid.net',
  #   :port           => '587',
  #   :authentication => :plain,
  #   :user_name      => ENV['SENDGRID_USERNAME'],
  #   :password       => ENV['SENDGRID_PASSWORD'],
  #   :domain         => 'heroku.com',
  #   :enable_starttls_auto => true
  # }
  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.middleware.use ExceptionNotifier,
    :email_prefix => "[LoveTax production] ",
    :sender_address => %{"Exception Notifier" <errors@makeloveland.com>},
    :exception_recipients => %w{awesome@kateray.net}

  Paperclip.options[:command_path] = "/usr/bin"
end


# Omniauth / loveland app ids
#APP_ID = 'lovetax'
#APP_SECRET = 'vie402jv00v,53n2xxyBZ'
#CUSTOM_PROVIDER_URL = 'http://makeloveland.com'

#Rails.application.config.middleware.use OmniAuth::Builder do
#  provider :josh_id, APP_ID, APP_SECRET
#end



