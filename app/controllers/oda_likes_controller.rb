class OdaLikesController < ApplicationController
  # GET /oda_likes
  # GET /oda_likes.json
  def index
    @oda_likes = OdaLike.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @oda_likes }
    end
  end

  # GET /oda_likes/1
  # GET /oda_likes/1.json
  def show
    @oda_like = OdaLike.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @oda_like }
    end
  end

  # GET /oda_likes/new
  # GET /oda_likes/new.json
  def new
    @oda_like = OdaLike.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @oda_like }
    end
  end

  # GET /oda_likes/1/edit
  def edit
    @oda_like = OdaLike.find(params[:id])
  end

  # POST /oda_likes
  # POST /oda_likes.json
  def create
    @oda_like = OdaLike.new(params[:oda_like])

    respond_to do |format|
      if @oda_like.save
        format.html { redirect_to @oda_like, notice: 'Oda like was successfully created.' }
        format.json { render json: @oda_like, status: :created, location: @oda_like }
      else
        format.html { render action: "new" }
        format.json { render json: @oda_like.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /oda_likes/1
  # PUT /oda_likes/1.json
  def update
    @oda_like = OdaLike.find(params[:id])

    respond_to do |format|
      if @oda_like.update_attributes(params[:oda_like])
        format.html { redirect_to @oda_like, notice: 'Oda like was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @oda_like.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /oda_likes/1
  # DELETE /oda_likes/1.json
  def destroy
    @oda_like = OdaLike.find(params[:id])
    @oda_like.destroy

    respond_to do |format|
      format.html { redirect_to oda_likes_url }
      format.json { head :no_content }
    end
  end
end
