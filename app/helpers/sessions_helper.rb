module SessionsHelper
    # When a user is authenticated, we store a remember_token
    # in the user's cookies and set that user as current_user.
    # 
    # If current user gets lost, it's reclaimed by current_user
    #
    # On sign out, remember_token is cleared from the user's
    # cookies and current_user is set to nil.

	
	def current_user_is_aiddata_admin
		# this finds out whether the current user is signed_in, admin, and belongs to AidData
		current_user_is_aiddata && current_user.admin? 
	end

  def aiddata_only!
    if !current_user_is_aiddata
      redirect_to signin_url
    end
  end

	def current_user_is_project_owner
		signed_in? && @project && @project.owner && current_user.owner && @project.owner_id == current_user.owner_id
	end 
	
	def current_user_is_aiddata
		signed_in? && current_user.owner && current_user.owner_id == Organization.aiddata.id
	end
	
  def sign_in_(user)
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
      redirect_to signin_url, notice: "Please sign in or create an account."
    end
  end

  def signed_in_and_same_owner
    if current_user.present?
      @user = User.find(params[:id])
      unless @user.owner_id.nil? || (current_user.owner == @user.owner && signed_in?)
        store_location
        redirect_to users_path, notice: "You must be in the user's organization to see this page."
      end
    else
        store_location
        redirect_to users_path, notice: "You must be in the user's organization to see this page."
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end
  
end
