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

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, 
      with: lambda { |exception| render_error 500, exception }

    rescue_from ActionController::RoutingError, 
                ActionController::UnknownController, 
                ::AbstractController::ActionNotFound, 
                ActiveRecord::RecordNotFound, 
                with: lambda { |exception| render_error 404, exception }
  end

  private
  def render_error(status, exception)
    respond_to do |format|
      format.html { render template: "errors/error_#{status}", 
                    layout: 'layouts/application', status: status }
      format.all { render nothing: true, status: status }
    end
  end

end
