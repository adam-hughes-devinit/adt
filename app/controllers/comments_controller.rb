class CommentsController < ApplicationController  
  skip_before_filter :signed_in_user, only: [:create]
  cache_sweeper :project_sweeper # app/models/project_sweeper.rb
  include SpamHelper

  def create

    unless params[:definitely_came_from_web_form]==true && !params[:comment][:content].is_spam_content?
      flash[:error] = "Sorry -- that looks like spam! Don't include HTML in your comment."
    else
      puts params[:comment]
      puts params[:geometry]
      puts params[:base64_media_item]
      if params[:base64_media_item][:media_data]!="" && params[:base64_media_item][:content_type]!="" && params[:base64_media_item][:original_filename]!=""
        mediabase64 = params[:base64_media_item][:media_data]
        base64 = mediabase64[mediabase64.index('base64')+7,mediabase64.length]
        decoded_data = Base64.decode64(base64)
        data = StringIO.new(decoded_data)
        data.class_eval do
          attr_accessor :content_type, :original_filename
        end
        data.content_type = params[:base64_media_item][:content_type]
        data.original_filename = File.basename(params[:base64_media_item][:original_filename])
        @base64_media_item = Base64MediaItem.new(:media=>data)
        @base64_media_item.save
        puts "base64_media_item"
        puts @base64_media_item.to_yaml
        puts "comment"
        puts @comment.to_yaml
      end
      #if(params[:geometry][:latitude]!="" && params[:geometry][:longitude]!="")
        #point = RGeo::Feature::Factory.point(params[:geometry][:longitude],params[:geometry][:latitude])
        #puts point.to_yaml
      #end
      @comment = Comment.new(params[:comment])
      if (not current_user)
        @comment.published = false
      end

      if @comment.save
        AiddataAdminMailer.delay.comment_notification(@comment)
        if current_user
          AiddataAdminMailer.delay.contributor_notification(@comment, @comment.project, current_user)
          flash[:success] = "Thanks for your contribution! Your comment has been added."
        else
          flash[:success] = "Thanks for your contribution! Your comment will be reviewed before being posted."
        end
      else
        flash[:error] = "Sorry, your comment wasn't saved: #{@comment.errors.full_messages.join ", "}"
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
