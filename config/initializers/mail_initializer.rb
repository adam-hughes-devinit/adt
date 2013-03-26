require 'yaml'
APP_CONFIG = YAML.load(File.read(Rails.root.to_s + "/config/app_config.yml"))
p "Make sure you put mailer information in /config/app_config.yml!"

ActionMailer::Base.smtp_settings = {
  :user_name            => APP_CONFIG['smtp_username'],
  :password             => APP_CONFIG['smtp_password'],
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :authentication       => "plain",
  :openssl_verify_mode  => 'none',
  :enable_starttls_auto => 'true'
}
