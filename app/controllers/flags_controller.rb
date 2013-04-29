class FlagsController < ApplicationController

skip_before_filter :signed_in_user, only: [:create]

cache_sweeper :project_sweeper # app/models/project_sweeper.rb

	def new 
		@flag = Flag.new
	end
	
	def create
		@flag = Flag.new(params[:flag])
		if not current_user
			ReviewEntry.add_item(@flag)
     		flash[:notice] = "Comment will be reviewed before being posted"
    	elsif @flag.save!
			AiddataAdminMailer.delay.flag_notification(@flag)
			flash[:success] = "Flag added"
		else
			flash[:message] = "Flag failed"
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
