class CommentsController < ApplicationController  
skip_before_filter :signed_in_user, only: [:create]
cache_sweeper :project_sweeper # app/models/project_sweeper.rb

	def create
		@comment = Comment.new(params[:comment])
		if @comment.save!
			AiddataAdminMailer.delay.comment_notification(@comment)
			flash[:success] = "Comment added."
			redirect_to :back
		else
			flash[:notice] = "Comment failed."
		end
		
	end

	def destroy
		@comment = Comment.find(params[:id])
		if @comment.destroy
			flash[:success] = "Comment deleted."
		else 
			flash[:notice] = "Comment not deleted."
		end
		redirect_to :back
	end

	def show 
		@comment = Comment.find(params[:id])
		@project = Project.find(@comment.project_id)
		redirect_to @project
	end



end
