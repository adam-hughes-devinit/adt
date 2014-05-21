source 'http://rubygems.org'

ruby '2.0.0'
gem 'rails', '3.2.13' #most up-to-date is 3.2.16, but this may be causing issues.
gem 'capistrano'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'faker', '1.1.2'
gem 'will_paginate'
gem 'bootstrap-will_paginate'
gem 'simple_form'
gem 'paper_trail'
gem 'sunspot_rails', '2.1.0'
gem 'thin'
gem 'dalli'
gem 'memcachier'
gem 'markdown-rails'
gem 'progress_bar'
gem 'daemons'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'pg'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin'
gem 'omniauth-weibo-oauth2'
gem 'haml', '~>4.0'
gem 'barista'
gem 'multipart-post'
gem 'sitemap_generator'
gem 'hashie'
gem 'aws-sdk'
gem 'newrelic_rpm'
gem 'exception_notification'
gem 'activeadmin', '0.6.0'
gem 'sass-rails'
gem "meta_search",    '>= 1.1.0.pre'
gem "paperclip", "~> 3.5.3"  #note: if upgrade to 4.1, all paperclip models need content type validation.
gem "flexslider" # for file viewer
gem 'active_admin_editor' # html editor for active admin
gem "rails-file-icons"
gem 'detect_language'
gem 'pdf-reader'
gem 'activerecord-postgis-adapter' # for postgis
gem 'smarter_csv' # For csv upload
gem 'squeel' # Allows for better postgis db queries.
gem 'rgeo'
gem 'rgeo-geojson' # converts hash to geojson for dashboard

group :production do
  gem 'unicorn'
end

group :development do
  gem 'quiet_assets'
end

group :test do
  gem 'sqlite3', '1.3.5'
  gem 'rspec-rails'
  gem 'factory_girl_rails', :require => false
  gem 'sunspot_solr', '2.1.0'
  gem 'launchy'
  gem 'spork-rails'
  gem 'database_cleaner'
  gem 'capybara'
  # gem 'capybara-webkit'
  gem 'selenium-webdriver'
  # gem 'ruby-debug'
  # gem 'brakeman', require: false
end


# group :assets do
# not available for dynamic compiling 
# if they're in this group
  #gem 'sass-rails',   '3.2.5'  # old version used, updated for active admin. Leaving this in case a bug arises.
  gem 'bootstrap-sass', '2.3.2.0'
  #gem 'bootstrap-sass', '3.0.2.1'
  gem 'coffee-rails', '3.2.2'
  gem 'uglifier', '1.2.3'
  gem "jquery-rails", "< 3.0.0" # this version needed for active admin to work (unless you upgrade to rails 4.0)
  #gem "jquery-rails"
# end

