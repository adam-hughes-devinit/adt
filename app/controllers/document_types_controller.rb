class DocumentTypesController < ApplicationController
  # GET /document_types
  # GET /document_types.json
  def index
    @document_types = DocumentType.all
    render template: 'shared/code_index', locals: {objects: @document_types, type: "Document Types"}
  end

  # GET /document_types/1
  # GET /document_types/1.json
  def show
    @document_type = DocumentType.find(params[:id])
    render template: 'shared/code', locals: {object: @document_type, type: "Document Type"}
  end

  # GET /document_types/new
  # GET /document_types/new.json
  def new
    @document_type = DocumentType.new
    render template: 'shared/code_form', locals: {object: @document_type, type: "Document Type"}
  end

  # GET /document_types/1/edit
  def edit
    @document_type = DocumentType.find(params[:id])
    render template: 'shared/code_form', locals: {object: @document_type, type: "Document Type"}
  end

  # POST /document_types
  # POST /document_types.json
  def create
    @document_type = DocumentType.new(params[:document_type])

    respond_to do |format|
      if @document_type.save
        format.html { redirect_to @document_type, notice: 'Document Type was successfully created.' }
        format.json { render json: @document_type, status: :created, location: @document_type }
      else
        format.html { render action: "new" }
        format.json { render json: @document_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /document_types/1
  # PUT /document_types/1.json
  def update
    @document_type = DocumentType.find(params[:id])

    respond_to do |format|
      if @document_type.update_attributes(params[:document_type])
        format.html { redirect_to @document_type, notice: 'DocumentType was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @document_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /document_types/1
  # DELETE /document_types/1.json
  def destroy
    @document_type = DocumentType.find(params[:id])
    @document_type.destroy

    respond_to do |format|
      format.html { redirect_to document_types_url }
      format.json { head :no_content }
    end
  end
end
