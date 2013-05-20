class RelationshipsController < ApplicationController

	def create
		@relationship = Relationship.new(params[:relationship])
		if @relationship.save!
			flash[:success] = "Follow added."
		else
			flash[:error] = "Follow not added."
		end
		redirect_to :back
	end	

	def destroy
		@relationship = Relationship.find(params[:id])
		if @relationship.destroy
			flash[:success] = "Follow removed."
		else
			flash[:error] = "Follow not removed."
		end
		redirect_to :back
	end
end