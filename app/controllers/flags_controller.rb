class FlagsController < ApplicationController

  skip_before_filter :signed_in_user, only: [:create]

  cache_sweeper :project_sweeper # app/models/project_sweeper.rb

  def new 
    @flag = Flag.new
  end

  def create
    # A chill hack to try to prevent spam...
    unless params[:definitely_came_from_web_form] && params[:flag][:flaggable_id]
      flash[:error] = "Please use the web form to submit flags!"
    else
      @flag = Flag.new(params[:flag])
      if not current_user && @flag.valid?
        p "Making review entry"
        ReviewEntry.add_item(@flag)
        flash[:success] = "Thanks for your contribution! Your flag will be reviewed before being posted."

      elsif @flag.save!
        AiddataAdminMailer.delay.flag_notification(@flag)
        flash[:success] = "Thanks for your contribution! Your flag was added."
      else
        flash[:message] = "Sorry - your flag wasn't saved. Please try again!"
      end
      p "flash: #{flash.inspect}"
      ProjectSweeper.instance.expire_cache_for(@flag) 
      # Otherwise the user won't see the flash -- it would be served straight from cache!
    end

    redirect_to :back
  end

  def destroy
    @flag = Flag.find(params[:id])
    if @flag.destroy
      flash[:success] = "Flag deleted."
    else 
      flash[:notice] = "Flag not deleted."
    end
    redirect_to :back
  end

  def show 
    @flag = Flag.find(params[:id])
    @target = (@flag.flaggable_type.constantize).find(@flag.flaggable_id).project
    redirect_to @target
  end

end
