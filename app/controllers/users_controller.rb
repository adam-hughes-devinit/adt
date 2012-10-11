class UsersController < ApplicationController
skip_before_filter :signed_in_user, only: [:new, :create]
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
      redirect_back_or user
  	else
  		render 'new'
  	end

  end

end
