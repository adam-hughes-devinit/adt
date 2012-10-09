class VerifiedsController < ApplicationController
  # GET /verifieds
  # GET /verifieds.json
  def index
    @verifieds = Verified.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @verifieds }
    end
  end

  # GET /verifieds/1
  # GET /verifieds/1.json
  def show
    @verified = Verified.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @verified }
    end
  end

  # GET /verifieds/new
  # GET /verifieds/new.json
  def new
    @verified = Verified.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @verified }
    end
  end

  # GET /verifieds/1/edit
  def edit
    @verified = Verified.find(params[:id])
  end

  # POST /verifieds
  # POST /verifieds.json
  def create
    @verified = Verified.new(params[:verified])

    respond_to do |format|
      if @verified.save
        format.html { redirect_to @verified, notice: 'Verified was successfully created.' }
        format.json { render json: @verified, status: :created, location: @verified }
      else
        format.html { render action: "new" }
        format.json { render json: @verified.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /verifieds/1
  # PUT /verifieds/1.json
  def update
    @verified = Verified.find(params[:id])

    respond_to do |format|
      if @verified.update_attributes(params[:verified])
        format.html { redirect_to @verified, notice: 'Verified was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @verified.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /verifieds/1
  # DELETE /verifieds/1.json
  def destroy
    @verified = Verified.find(params[:id])
    @verified.destroy

    respond_to do |format|
      format.html { redirect_to verifieds_url }
      format.json { head :no_content }
    end
  end
end
