class CommentsController < ApplicationController  
  skip_before_filter :signed_in_user, only: [:create]
  cache_sweeper :project_sweeper # app/models/project_sweeper.rb
  include SpamHelper

  def create

    unless params[:definitely_came_from_web_form] && !params[:comment][:content].is_spam_content?
      flash[:error] = "Sorry -- that looks like spam! Don't include HTML in your comment."
    else

      @comment = Comment.new(params[:comment])
      if (not current_user)
        @comment.published = false
      end

      if @comment.save
        AiddataAdminMailer.delay.comment_notification(@comment)
        if current_user
          flash[:success] = "Thanks for your contribution! Your comment has been added."
        else
          flash[:success] = "Thanks for your contribution! Your comment will be reviewed before being posted."
        end
      else
        flash[:error] = "Sorry -- that operation failed, please try again."
      end
      ProjectSweeper.instance.expire_cache_for(@comment) 
      # Otherwise the user won't see the flash -- it would be served straight from cache!
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
