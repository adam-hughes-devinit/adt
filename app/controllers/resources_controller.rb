class ResourcesController < ApplicationController
  skip_before_filter :signed_in, only: [:search]
  # GET /resources
  # GET /resources.json
  def index
    order_by = params[:order]
    dir = params[:dir] # ASC / DESC
    @resources = Resource.order("#{order_by} #{dir}").page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resources }
    end
  end

  def search
    @search = Resource.search do
      fulltext params[:search]
      paginate :page => params[:page] || 1, :per_page => params[:max] || 50
    end
    @resources = @search.results
    
    if params[:typeahead]
      render json: @resources.map{ |r| {value: r.id, english: r.to_citation, tokens: r.to_citation.split(" ")}}
    else
      render 'index'
    end

  end

  # GET /resources/1
  # GET /resources/1.json
  def show
    @resource = Resource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource }
    end
  end

  # GET /resources/new
  # GET /resources/new.json
  def new
    @resource = Resource.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource }
    end
  end

  # GET /resources/1/edit
  def edit
    @resource = Resource.find(params[:id])
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(params[:resource])

    respond_to do |format|
      if @resource.save
        format.html { redirect_to @resource, notice: 'Resource was successfully created -- now fetching...' }
        format.json { render json: @resource, status: :created, location: @resource }
      else
        format.html { render action: "new" }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /resources/1
  # PUT /resources/1.json
  def update
    @resource = Resource.find(params[:id])

    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        format.html { redirect_to @resource, notice: 'Resource was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end



end
