class CodesController < ApplicationController
  # GET /flow_types
  # GET /flow_types.json
  def index
    @objects = @class_name.constantize.all

    respond_to do |format|
      format.html {render template: 'shared/code_index', locals: {objects: @objects, type: @class_type.pluralize}}
      format.json { render json: @objects }
    end
  end

  # GET /flow_types/1
  # GET /flow_types/1.json
  def show
    @object = @class_name.constantize.find(params[:id])

    respond_to do |format|
      format.html { render template: 'shared/code', locals: {object: @object, type: @class_type}}
      format.json { render json: @object }
    end
  end

  # GET /flow_types/new
  # GET /flow_types/new.json
  def new
    @object = @class_name.constantize.new

    respond_to do |format|
      format.html {render template: 'shared/code_form', locals: {object: @object, type: @class_type}}
      format.json { render json: @object }
    end
  end

  # GET /flow_types/1/edit
  def edit
    @object = @class_name.constantize.find(params[:id])
    render template: 'shared/code_form', locals: {object: @object, type: @class_type}
  end

  # POST /flow_types
  # POST /flow_types.json
  def create
    @object = @class_name.constantize.new(params[@class_name.underscore.downcase.to_sym])

    respond_to do |format|
      if @object.save
        format.html { redirect_to @object }
        format.json { render json: @object, status: :created, location: @object }
      else
        format.html { render action: "new" }
        format.json { render json: @object.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /flow_types/1
  # PUT /flow_types/1.json
  def update
    @object = @class_name.constantize.find(params[:id])

    respond_to do |format|
      if @object.update_attributes(params[@class_type.downcase.gsub(/\s/, '_').to_sym])

        format.html { redirect_to @object}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @object.errors, status: :unprocessable_entity }
      end
    end

    undo_link = view_context.link_to( 
    "Undo", revert_version_path(@object.versions.scoped.last
    ),
    #"Undo", "/versions/#{@object.versions.last.id}/revert",
    method: :post)
    flash[:success] = "#{@class_type} updated. #{undo_link}"
  end

  # DELETE /flow_types/1
  # DELETE /flow_types/1.json
  def destroy
    @object = @class_name.constantize.find(params[:id])
    @object.destroy

    respond_to do |format|
      format.html { redirect_to flow_types_url }
      format.json { head :no_content }
    end
  end

  private
  	def create_local_variables(class_name_val, class_type_val, options={})
  		@class_name = class_name_val
  		@class_type = class_type_val
  		options.reverse_merge!({has_projects: true})
  		@has_projects = options[:has_projects]
  	end
end
