class UsersController < ApplicationController
before_filter :signed_in_user, except: [:new, :create]
before_filter :signed_in_and_same_owner, only: [:show]

  def index
    @users = User.all
  end

  def new
  		@user=User.new
  end

  def show
  	@user=User.find(params[:id])
  end

  def create
  	@user = User.new(params[:user])
  	if @user.save
      sign_in @user
      redirect_back_or @user
  	else
  		render 'new'
  	end
  end

  def own
    @user = User.find_by_id(params[:id])
    @user.update_attribute(:owner, Organization.find_by_id(params[:owner_id]))
    redirect_to users_path
  end

  def disown
    @user = User.find_by_id(params[:id])
    @user.update_attribute(:owner, nil)
    redirect_to users_path
  end

end
