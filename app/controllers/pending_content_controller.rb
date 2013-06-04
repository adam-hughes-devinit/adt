class PendingContentController < ApplicationController

  def index
    @pending_content = []
    if %w{projects comments flags}.include? params[:pending_content_scope]   
      this_scope = params[:pending_content_scope]
      class_name = this_scope.singularize.titleize
      @pending_content << class_name.constantize.where(published: false)
    else
      @pending_content << @projects = Project.where(published: false)
      @pending_content << @flags = Flag.where(published: false)
      @pending_content << @comments = Comment.where(published: false)
    end
  end

  def approve
    @content = get_content(params)
    @content.published = true
    @content.save
    AiddataAdminMailer.pending_content_notification(@content, true).deliver
    render json: true
  end

  def destroy
    @content = get_content(params)
    @content.destroy
    AiddataAdminMailer.pending_content_notification(@content, false).deliver
    render json: true
  end

  private

  def get_content(param_hash)
    class_name = param_hash[:class_name]
    id = param_hash[:id]
    class_name.constantize.unscoped.find_by_id!(id)
  end
end
