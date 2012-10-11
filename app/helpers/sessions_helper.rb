module SessionsHelper
    # When a user is authenticated, we store a remember_token
    # in the user's cookies and set that user as current_user.
    # 
    # If current user gets lost, it's reclaimed by current_user
    #
    # On sign out, remember_token is cleared from the user's
    # cookies and current_user is set to nil.


  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end

  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  # not sure if I'll need these

    def current_user?(user)
      user == current_user
    end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end
  
end
