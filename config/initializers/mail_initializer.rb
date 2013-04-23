require 'yaml'
if !ENV["smtp_username"]
	APP_CONFIG = YAML.load(File.read(Rails.root.to_s + "/config/app_config.yml"))
	p "Make sure you put mailer information in /config/app_config.yml!"
else
	APP_CONFIG = {}
end

ActionMailer::Base.smtp_settings = { user_name: ENV["smtp_username"] || APP_CONFIG['smtp_username'],
                                     password: ENV["smtp_password"] || APP_CONFIG['smtp_password'],
                                     address: 'smtp.gmail.com',
                                     port: 587,
                                     authentication: :plain,
                                     enable_starttls_auto: true,
}
