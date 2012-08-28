# Load the rails application
require File.expand_path('../application', __FILE__)

ActionMailer::Base.smtp_settings = {
  :user_name            => ENV['SMTP_USER'],
  :password             => ENV['SMTP_PASS'],
  :domain               => ENV['SMTP_DOMAIN'],
  :address              => ENV['SMTP_ADDRESS'],
  :port                 => 587,
  :authentication       => :plain,
  :enable_starttls_auto => true
}

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tax', 'taxes'
end

Miley.setup do |s|
  s.appname = 'awesometax'
end


# Initialize the rails application
LoveTax3::Application.initialize!
