class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  before_filter :signed_in_user, except: [:index, :show, :twitter_typeahead]
  before_filter :mailer_set_url_options
  
  before_filter :redirect_if_heroku
  
  def redirect_if_heroku
    if Rails.env.production? && ENV['PGBACKUPS_URL'] # That's a heroku plugin
      redirect_to "http://wm.aiddata.org#{request.fullpath}"
    end
  end



  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, 
      with: lambda { |exception| render_error 500, exception }

    # rescue_from ActionController::RoutingError, 
    #             ActionController::UnknownController, 
    #             ::AbstractController::ActionNotFound, 
    #             ActiveRecord::RecordNotFound, 
    rescue_from ActiveRecord::RecordNotFound, 
                with: lambda { |exception| render_error 404, exception }
  end

  private
  def render_error(status, exception)
    respond_to do |format|
      p exception
      format.html { render template: "errors/error_#{status}", 
                    layout: 'layouts/application', status: status }
      format.all { render nothing: true, status: status }
    end
  end

end
