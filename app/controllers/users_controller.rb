class UsersController < ApplicationController
before_filter :signed_in_user, except: [:new, :create]
before_filter :signed_in_and_same_owner, only: [:show]

  def index

    order_by = params[:order]
    dir = params[:dir] # ASC / DESC

    @users = User.order("#{order_by} #{dir}").page(params[:page])
  end

  def new
  		@user=User.new
  end

  def show
    @user=User.find(params[:id])
  end  

  def edit
    @user=User.find(params[:id])
  end

  def update 
    @user=User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end

    if @user.versions.scoped.last
      undo_link = view_context.link_to( 
      "Undo", revert_version_path(@user.versions.scoped.last
      ),
      method: :post)
    else 
      undo_link = ''
    end

      flash[:success] = "User updated. #{undo_link}"
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

  def destroy
    @user = User.find_by_id(params[:id])
    @user.destroy
    flash[:notice] = "User deleted."
    redirect_to users_path
  end
  

end
