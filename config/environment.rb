# Load the rails application
require File.expand_path('../application', __FILE__)

ActionMailer::Base.smtp_settings = {
  :user_name            => "lsheradon",
  :password             => "gem17years",
  :domain               => 'makeloveland.com',
  :address              => "smtp.sendgrid.net",
  :port                 => 587,
  :authentication       => :plain,
  :enable_starttls_auto => true
}

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tax', 'taxes'
end

Miley.setup do |s|
  s.host = '127.0.0.1'
  s.appname = 'awesometax'
end


# Initialize the rails application
LoveTax3::Application.initialize!
