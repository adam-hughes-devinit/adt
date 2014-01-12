class ResourcesController < ApplicationController
  skip_before_filter :signed_in, only: [:search]

  extend Typeaheadable
  enable_typeahead Resource

  def index

    search = Resource.solr_search do
      fulltext params[:search] if params[:search].present?
      with :resource_type, params[:resource_type] if params[:resource_type].present? && params[:resource_type] != [""]
      with :language_id, params[:language_id] if params[:language_id].present? && params[:language_id] != [""]
      order_by params[:order] ? params[:order].to_sym : :title, params[:dir] ? params[:dir].to_sym : :asc
      paginate page: params[:page] || 1, per_page: 30
    end

    @resources = search.results
    @languages = Language.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resources }
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

  def get_devoured 
    @resource = Resource.find(params[:id])
    @devourer = Resource.find(params[:devourer_id])

    if @devourer.devour! @resource
      redirect_to @devourer
    else
      redirect_to :back
    end
  end



end
