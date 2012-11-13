class ApplicationController < ActionController::Base
  before_filter :signed_in_user, except: [:index, :show]
  protect_from_forgery
  include SessionsHelper
  if Rails.env.production?
  	http_basic_authenticate_with name:'aiddata_china', password: 'a1dd4t4'
  end


end
