class StatusesController < ApplicationController

	def new
		@status=Status.new
	end

	def create
		@status = Status.new(params[:status])
		if @status.save
			flash[:success] = "Status Created"
			redirect_to @status
		else
			#flash.now[:error] = "Status Failed"
			render 'new'
		end

	end

	def destroy
	end

	def update
	end

	def index 
	end

	def show
		@status=Status.find_by_id(params[:id])
	end


end
