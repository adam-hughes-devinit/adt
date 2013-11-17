class MediaItemsController < ApplicationController
  # GET /media_items
  # GET /media_items.json
  def index
    @media_items = MediaItem.all

  #  respond_to do |format|
  #    format.html # index.html.erb
  #    format.json { render json: @media_items }
  #  end
  end

  # GET /media_items/1
  # GET /media_items/1.json
  def show
    @media_item = MediaItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @media_item }
    end
  end

  # GET /media_items/new
  # GET /media_items/new.json
  def new
    @media_item = MediaItem.new


    redirect_to Project.find(params[:project_id])

    #respond_to do |format|
    #  format.html # new.html.erb
    #  format.json { render json: @media_item }
    #end
  end

  # GET /media_items/1/edit
  def edit
    @media_item = MediaItem.find(params[:id])
  end

  # POST /media_items
  # POST /media_items.json
  def create
    @media_item = MediaItem.create(params[:media_item])
    @project = Project.find(params[:project_id])
    @media_item.project_id = @project.id
    @media_item.media = params[:media]
    @media_item.publish = 'f'
    @media_item.downloadable ='f'
    @media_item.url = params[:url]
    @media_item.user_id  = params[:user_id]





    respond_to do |format|
      if @media_item.save
        format.html { redirect_to @project, notice: 'Media item was successfully created.' }
        format.json { render json: @media_item, status: :created, location: @media_item }
      else
        #format.html { render action: "new" }
        format.html { redirect_to @project, notice: 'Error: Media item was not saved!' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /media_items/1
  # PUT /media_items/1.json
  def update
    @media_item = MediaItem.find(params[:id])

    respond_to do |format|
      if @media_item.update_attributes(params[:media_item])
        format.html { redirect_to @media_item, notice: 'Media item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @media_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /media_items/1
  # DELETE /media_items/1.json
  def destroy
    @media_item = MediaItem.find(params[:id])
    @media_item.destroy
    @project = Project.find(params[:project_id])

    respond_to do |format|
      format.html { redirect_to @project, notice: 'Media item was deleted' }
      format.json { head :no_content }
    end
  end
end
