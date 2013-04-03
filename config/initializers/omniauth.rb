OmniAuth.config.logger = Rails.logger

OMNIAUTH_CONFIG = YAML.load(File.read(Rails.root.to_s + "/config/omniauth_config.yml"))
Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, OMNIAUTH_CONFIG['facebook_key'],
                        OMNIAUTH_CONFIG['facebook_secret']
    provider :twitter, OMNIAUTH_CONFIG['twitter_key'],
                        OMNIAUTH_CONFIG['twitter_secret']
    provider :google_oauth2, OMNIAUTH_CONFIG['google_key'],
                        OMNIAUTH_CONFIG['google_secret']
    provider :linkedin, OMNIAUTH_CONFIG['linkedin_key'],
                        OMNIAUTH_CONFIG['linkedin_secret']
end
