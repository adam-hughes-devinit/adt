class TiedsController < ApplicationController
  # GET /tieds
  # GET /tieds.json
  def index
    @tieds = Tied.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tieds }
    end
  end

  # GET /tieds/1
  # GET /tieds/1.json
  def show
    @tied = Tied.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tied }
    end
  end

  # GET /tieds/new
  # GET /tieds/new.json
  def new
    @tied = Tied.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tied }
    end
  end

  # GET /tieds/1/edit
  def edit
    @tied = Tied.find(params[:id])
  end

  # POST /tieds
  # POST /tieds.json
  def create
    @tied = Tied.new(params[:tied])

    respond_to do |format|
      if @tied.save
        format.html { redirect_to @tied, notice: 'Tied was successfully created.' }
        format.json { render json: @tied, status: :created, location: @tied }
      else
        format.html { render action: "new" }
        format.json { render json: @tied.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tieds/1
  # PUT /tieds/1.json
  def update
    @tied = Tied.find(params[:id])

    respond_to do |format|
      if @tied.update_attributes(params[:tied])
        format.html { redirect_to @tied, notice: 'Tied was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tied.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tieds/1
  # DELETE /tieds/1.json
  def destroy
    @tied = Tied.find(params[:id])
    @tied.destroy

    respond_to do |format|
      format.html { redirect_to tieds_url }
      format.json { head :no_content }
    end
  end
end
