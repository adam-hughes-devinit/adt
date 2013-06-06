class PinnedProjectsController < ApplicationController

  def index
    @resource = Resource.find(params[:resource_id])
    render json: @resource.projects
  end

  def create
    @resource = Resource.find(params[:resource_id])
    @project = Project.find(params[:project_id])
    @resource.projects << @project
    if @resource.save
      render json: {"status" =>  "success", "project" => @project.to_english }
    else
      render json: {"status" =>  "failed"}
    end
  end

  def destroy
    @resource = Resource.find(params[:resource_id])
    @resource.projects.delete Project.find(params[:id])
    if @resource.save
      render json: {"status" => "success"}
    else
      render json: {"status" =>  "failed"}
    end
  end

end
