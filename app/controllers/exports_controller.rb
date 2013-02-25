class ExportsController < ApplicationController
  def index
    @exports = Export.all
  end

  def show
    @export = Export.find(params[:id])
    respond_to do |format|
      format.html #show.html.erb
      @export[:status_percent] = @export.status_percent
      format.json { render json: @export }
    end
  end

  def new
  end

  def update
  end

  def create
    projects_string = params[:export][:projects]
    projects_string.gsub!(/[\[\]]/,'')
    projects_array = []

    project_count = projects_string.count(',')
    # percentage_update = (45.0 / project_count) * 10
    projects_string.split(",").each_with_index.map do |proj_id, index|
      # if index % 10 == 0
      #   @export.status_percent += percentage_update
      #   @export.save
      # end
      proj_id.strip!
      projects_array << Project.find(proj_id.to_i)
    end
    params[:export][:projects] = projects_array

    @export = Export.new(params[:export])
    if @export.save
			 ExportMailer.delay.export_request(@export, params[:export][:email])
      redirect_to(@export)
    else
      render action: "new"
    end
  end

end
