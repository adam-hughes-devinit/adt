class CommentsController < ApplicationController  
skip_before_filter :signed_in_user, only: [:create]
cache_sweeper :project_sweeper # app/models/project_sweeper.rb

	def create
		@comment = Comment.new(params[:comment])
    if not current_user
      ReviewEntry.add_item(@comment)
      flash[:notice] = "Thanks for your contribution! Your comment will be reviewed before being posted."
     ProjectSweeper.instance.expire_cache_for(@comment) # Otherwise the user won't see the flash -- it would be served straight from cache!

    elsif @comment.save!
      AiddataAdminMailer.delay.comment_notification(@comment)
      flash[:success] = "Thanks for your contribution! Your comment has been added."
    else
      flash[:notice] = "Sorry -- that operation failed, please try again."
    end
    redirect_to :back
		
	end

	def destroy

		@comment = Comment.find(params[:id])
		@project = @comment.project

		if @comment.destroy
			flash[:success] = "Comment deleted."
		else 
			flash[:notice] = "Comment not deleted."
		end
		redirect_to @project
	end

	def show 
		@comment = Comment.find(params[:id])
		@project = Project.find(@comment.project_id)
		redirect_to @project
	end



end
