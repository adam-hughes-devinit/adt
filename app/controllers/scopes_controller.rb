class ScopesController < ApplicationController

	def index
		@scopes = Scope.all
		respond_to do |format|
	      format.html { render html: @scopes}
	      format.json { render json: @scopes }
	    end
	end

	def new
		@scope = Scope.new
		@scope.build_scope_scaffold	
	end

	def show
		@scope = Scope.find(params[:id])

		respond_to do |format|
			format.html { render html: @scope }
			format.json { render json: @scope }
		end
	end
	
	def create		
		
		# prepare for serialization!
		params[:scope][:channels] = YAML.load(params[:scope][:channels])

		@scope = Scope.new(params[:scope])

		respond_to do |format|
			if @scope.save
				format.html { redirect_to @scope }
				format.json { render json: @scope, status: :created, location: @scope }
			else
				format.html { render action: "new" }
				format.json { render json: @scope.errors, status: :unprocessable_entity }
			end

		end
	end

	def edit
		@scope = Scope.find(params[:id])
	end

	def update
		@scope = Scope.find(params[:id])

		# prepare for serialization!
	    params[:scope][:channels] = YAML.load(params[:scope][:channels])
	    
	    respond_to do |format|
	      if @scope.update_attributes(params[:scope])
	        format.html { 
	        	flash[:success] = "Saved."
	        	redirect_to @scope }
	        format.json { head :no_content }
	      else
	        format.html { 
	        	flash[:error] = "Not saved"
	        	render action: "edit" }
	        format.json { render json: @scope.errors, status: :unprocessable_entity }
	      end
	    end

	end

	def destroy
		@scope = Scope.find(params[:id])

		@scope.destroy

		respond_to do |format|
	      format.html { redirect_to scopes_url }
	      format.json { head :no_content }
	    end
	end

end
