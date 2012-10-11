class OrganizationTypesController < ApplicationController
  # GET /organization_types
  # GET /organization_types.json
  def index
    @organization_types = OrganizationType.all
    render template: 'shared/code_index', locals: {objects: @organization_types, type: "Organization Types"}
  end

  # GET /organization_types/1
  # GET /organization_types/1.json
  def show
    @organization_type = OrganizationType.find(params[:id])
    render template: 'shared/code', locals: {object: @organization_type, type: "Organization Type"}
  end

  # GET /organization_types/new
  # GET /organization_types/new.json
  def new
    @organization_type = OrganizationType.new
    render template: 'shared/code_form', locals: {object: @organization_type, type: "Organization Type"}
  end

  # GET /organization_types/1/edit
  def edit
    @organization_type = OrganizationType.find(params[:id])
    render template: 'shared/code_form', locals: {object: @organization_type, type: "Organization Type"}
  end

  # POST /organization_types
  # POST /organization_types.json
  def create
    @organization_type = OrganizationType.new(params[:organization_type])

    respond_to do |format|
      if @organization_type.save
        format.html { redirect_to @organization_type, notice: 'Organization Type was successfully created.' }
        format.json { render json: @organization_type, status: :created, location: @organization_type }
      else
        format.html { render action: "new" }
        format.json { render json: @organization_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /organization_types/1
  # PUT /organization_types/1.json
  def update
    @organization_type = OrganizationType.find(params[:id])

    respond_to do |format|
      if @organization_type.update_attributes(params[:organization_type])
        format.html { redirect_to @organization_type, notice: 'OrganizationType was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @organization_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organization_types/1
  # DELETE /organization_types/1.json
  def destroy
    @organization_type = OrganizationType.find(params[:id])
    @organization_type.destroy

    respond_to do |format|
      format.html { redirect_to organization_types_url }
      format.json { head :no_content }
    end
  end
end
