class ApplicationController < ActionController::Base
  before_filter :signed_in_user, except: [:index, :show]
  protect_from_forgery
  include SessionsHelper

end
