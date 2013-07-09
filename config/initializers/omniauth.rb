OmniAuth.config.logger = Rails.logger


OMNIAUTH_FILE = Rails.root.to_s + "/config/omniauth_config.yml"

if File.exist? OMNIAUTH_FILE
    OMNIAUTH_CONFIG = YAML.load(File.read(OMNIAUTH_FILE))
else
    OMNIAUTH_CONFIG = {}
end

Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, (ENV["facebook_key"] || OMNIAUTH_CONFIG['facebook_key']),
                        (ENV["facebook_secret"] || OMNIAUTH_CONFIG['facebook_secret'])
    provider :twitter, (ENV["twitter_key"] || OMNIAUTH_CONFIG['twitter_key']),
                        (ENV["twitter_secret"] ||  OMNIAUTH_CONFIG['twitter_secret'])
    provider :google_oauth2,(ENV["google_key"] || OMNIAUTH_CONFIG['google_key']),
                        (ENV["google_secret"] || OMNIAUTH_CONFIG['google_secret'])
    provider :linkedin, (ENV["linkedin_key"] || OMNIAUTH_CONFIG['linkedin_key']),
                        (ENV["linkedin_secret"] || OMNIAUTH_CONFIG['linkedin_secret'])
    provider :weibo, (ENV["weibo_key"] || OMNIAUTH_CONFIG['weibo_key']),
                        (ENV["weibo_secret"] || OMNIAUTH_CONFIG['weibo_secret'])
end
