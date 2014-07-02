class SessionsController < ApplicationController
  skip_before_filter :signed_in_user

  def new
  end

  def create
    auth =  request.env["omniauth.auth"]

    if auth
      auth["uid"] = auth["uid"].to_s
      user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
      sign_in_ user
      redirect_back_or root_url
    else
      user = User.find_by_email(params[:session][:email].downcase)
      if user && user.authenticate(params[:session][:password])
        sign_in_ user
        redirect_back_or root_url
      else
        flash.now[:error] = 'Invalid email/password combination' # Not quite right!
        render 'new'
      end
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

end
