class ExportsController < ApplicationController
  def index
    @exports = Export.all
  end

  def show
    @export = Export.find(params[:id])
  end

  def new
  end

  def update
  end

  def create
    projects_string = params[:export][:projects]
    projects_string.gsub!(/[\[\]]/,'')
    projects_array = []
    projects_string.split(",").map do |proj_id|
      proj_id.strip!
      projects_array << Project.find(proj_id.to_i)
    end
    params[:export][:projects] = projects_array

    @export = Export.new(params[:export])
    if @export.save
      redirect_to(@export, notice: 'Post was successfully created.')
    else
      render action: "new"
    end
  end

end
