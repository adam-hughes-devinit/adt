class CodesController < ApplicationController

  def index
    @objects = @class_name.constantize.all

    respond_to do |format|
      format.html {render template: 'shared/code_index', locals: {objects: @objects, type: @class_type.pluralize}}
      format.json { render json: @objects }
    end
  end


  def show
    @object = @class_name.constantize.find(params[:id])

    respond_to do |format|
      format.html { render template: 'shared/code', locals: {object: @object, type: @class_type}}
      format.json { render json: @object }
    end
  end

  def new
    @object = @class_name.constantize.new
	
    respond_to do |format|
      format.html {render template: 'shared/code_form', locals: {object: @object, type: @class_type}}
      format.json { render json: @object }
    end
  end


  def edit
    @object = @class_name.constantize.find(params[:id])
    render template: 'shared/code_form', locals: {object: @object, type: @class_type}
  end

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
      
      reindex_and_recache
    end

    undo_link = view_context.link_to( 
    "Undo", revert_version_path(@object.versions.scoped.last
    ),
    #"Undo", "/versions/#{@object.versions.last.id}/revert",
    method: :post)
    flash[:success] = "#{@class_type} updated. #{undo_link}"
  end


  def destroy
    @object = @class_name.constantize.find(params[:id])
    remove_object_from_projects_and_reindex_and_recache   
    @object.destroy

    respond_to do |format|
      format.html { redirect_to "/#{view_context.pluralize(2, @class_type)[2..15].downcase.gsub(/\s/, '_')}" }
      format.json { head :no_content }
    end

  end

  private
  	def create_local_variables(class_name_val, class_type_val, options={})
  		@class_name = class_name_val # ex. OdaLike
  		@class_type = class_type_val # ex. Oda Like
  		options.reverse_merge!({has_projects: true})
  		@has_projects = options[:has_projects]
  	end
  	
  	def reindex_and_recache
  		# What's the best way to background this?
      if @object.respond_to? 'projects'
	  		Sunspot.index(@object.projects)
				@object.projects.each {|p| p.delay.cache_one!}
				# to update the master cache... -->
				@object.projects.first.delay.cache!
	  	end
  	end


  	def remove_object_from_projects_and_reindex_and_recache
  	  if @object.respond_to? 'projects'
  	  	@object.projects.each do |p|
			  	if p.respond_to? "{@class_name.underscore.downcase}_id"
			  		p.update_attribute "{@class_name.underscore.downcase}_id".to_sym, nil
					end
	  		end
	  		@object.projects.first.delay.cache!
	  		Sunspot.index(@object.projects)
	  	end
	  end

end
