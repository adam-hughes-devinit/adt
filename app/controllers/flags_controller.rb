class FlagsController < ApplicationController

	def new 
		@flag = Flag.new
	end
	
	def create
		@flag = Flag.new(params[:flag])
		if @flag.save!
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
