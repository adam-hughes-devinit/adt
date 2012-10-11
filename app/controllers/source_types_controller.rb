class SourceTypesController < ApplicationController
  # GET /source_types
  # GET /source_types.json
  def index
    @source_types = SourceType.all
    render template: 'shared/code_index', locals: {objects: @source_types, type: "Source Types"}
  end

  # GET /source_types/1
  # GET /source_types/1.json
  def show
    @source_type = SourceType.find(params[:id])
    render template: 'shared/code', locals: {object: @source_type, type: "Source Type"}
  end

  # GET /source_types/new
  # GET /source_types/new.json
  def new
    @source_type = SourceType.new
    render template: 'shared/code_form', locals: {object: @source_type, type: "Source Type"}
  end

  # GET /source_types/1/edit
  def edit
    @source_type = SourceType.find(params[:id])
    render template: 'shared/code_form', locals: {object: @source_type, type: "Source Type"}
  end

  # POST /source_types
  # POST /source_types.json
  def create
    @source_type = SourceType.new(params[:source_type])

    respond_to do |format|
      if @source_type.save
        format.html { redirect_to @source_type, notice: 'Source Type was successfully created.' }
        format.json { render json: @source_type, status: :created, location: @source_type }
      else
        format.html { render action: "new" }
        format.json { render json: @source_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /source_types/1
  # PUT /source_types/1.json
  def update
    @source_type = SourceType.find(params[:id])

    respond_to do |format|
      if @source_type.update_attributes(params[:source_type])
        format.html { redirect_to @source_type, notice: 'SourceType was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @source_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /source_types/1
  # DELETE /source_types/1.json
  def destroy
    @source_type = SourceType.find(params[:id])
    @source_type.destroy

    respond_to do |format|
      format.html { redirect_to source_types_url }
      format.json { head :no_content }
    end
  end
end
