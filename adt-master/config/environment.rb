# Load the rails application
require File.expand_path('../application', __FILE__)

secrets = File.join(Rails.root, 'config', 'secrets.rb')
load(secrets) if File.exists?(secrets)
# Initialize the rails application
Adt::Application.initialize!
