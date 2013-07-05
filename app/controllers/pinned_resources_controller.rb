class PinnedResourcesController < ApplicationController

  def index
    @project = Project.find(params[:project_id])
    render json: @project.resources
  end

  def show
    @resource = Resource.find(params[:id])
    render json: @resource
  end

  def create
    @project = Project.find(params[:project_id])
    @resource = Resource.find(params[:resource_id])
    @project.resources << @resource


    if @project.save!
      respond_to do |format|
        format.html {render partial: 'resources/form_inset', locals: {resource: @resource} } 
        format.json {render json: {"status" => "success", "resource" => @resource.to_citation}}
      end

    else
      render json: {"status" => "failure"}
    end
  end

  def destroy
    @project = Project.find(params[:project_id])
    @resource = Resource.find(params[:id])
    @project.resources.delete @resource
    if @project.save
      render json: {"status" => "success"}
    else
      render json: {"status" => "failure"}
    end
  end



end
