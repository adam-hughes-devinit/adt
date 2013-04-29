class ExportsController < ApplicationController
skip_before_filter :signed_in_user, only: [:create]

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

    projects_string.split(",").map do |proj_id|
      proj_id.strip!
      projects_array << Project.find(proj_id.to_i)
    end
    params[:export][:projects] = projects_array

    session[:return_to] ||= request.referer

    @export = Export.new(params[:export])
    if @export.save
			ExportMailer.delay.export_request(@export, params[:export][:email])
      redirect_to(@export)
    else
      redirect_to session[:return_to], :flash => {:error => "Sorry. Invalid email address."}
    end
  end
end
