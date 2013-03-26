class ApplicationController < ActionController::Base
  before_filter :signed_in_user, except: [:index, :show]
  before_filter :mailer_set_url_options
  
  protect_from_forgery
  
  include SessionsHelper
  
  if Rails.env.production?
  	http_basic_authenticate_with name:'aiddata_china', password: 'a1dd4t4'
  end

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

end
