class OriginsController < ApplicationController
  # GET /origins
  # GET /origins.json
  def index
    @origins = Origin.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @origins }
    end
  end

  # GET /origins/1
  # GET /origins/1.json
  def show
    @origin = Origin.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @origin }
    end
  end

  # GET /origins/new
  # GET /origins/new.json
  def new
    @origin = Origin.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @origin }
    end
  end

  # GET /origins/1/edit
  def edit
    @origin = Origin.find(params[:id])
  end

  # POST /origins
  # POST /origins.json
  def create
    @origin = Origin.new(params[:origin])

    respond_to do |format|
      if @origin.save
        format.html { redirect_to @origin, notice: 'Origin was successfully created.' }
        format.json { render json: @origin, status: :created, location: @origin }
      else
        format.html { render action: "new" }
        format.json { render json: @origin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /origins/1
  # PUT /origins/1.json
  def update
    @origin = Origin.find(params[:id])

    respond_to do |format|
      if @origin.update_attributes(params[:origin])
        format.html { redirect_to @origin, notice: 'Origin was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @origin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /origins/1
  # DELETE /origins/1.json
  def destroy
    @origin = Origin.find(params[:id])
    @origin.destroy

    respond_to do |format|
      format.html { redirect_to origins_url }
      format.json { head :no_content }
    end
  end
end
