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
    @export = Export.new(params[:export])
    if @export.save
      redirect_to(@export, notice: 'Post was successfully created.')
    else
      render action: "new"
    end
  end

end
