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
      render json: {"status" => "success", "resource" => @resource.to_citation}
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
