OmniAuth.config.logger = Rails.logger

OMNIAUTH_CONFIG = YAML.load(File.read(Rails.root.to_s + "/config/omniauth_config.yml"))
Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, OMNIAUTH_CONFIG['facebook_key'],
                        OMNIAUTH_CONFIG['facebook_secret']
end
