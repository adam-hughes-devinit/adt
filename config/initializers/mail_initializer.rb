require 'yaml'
APP_CONFIG = YAML.load(File.read(Rails.root.to_s + "/config/app_config.yml"))

ActionMailer::Base.smtp_settings = {
  :user_name            => APP_CONFIG['smtp_username'],
  :password             => APP_CONFIG['smtp_password'],
  :address              => "smtp.gmail.com",
  :authentication       => "plain",
  :openssl_verify_mode => 'none'
}
