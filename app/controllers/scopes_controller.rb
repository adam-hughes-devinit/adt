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
		# Make a dummy scope
		@scope = Scope.new()
		
		# get the data
		attrs = YAML::load(params[:scope])

		# Fill the dummy scope with data
		success = update_scope(@scope, attrs)

		respond_to do |format|
			if success
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

		attrs = YAML::load(params[:scope])

		success = update_scope(@scope, attrs)
		#flash[:notice] = "#{@scope.name} <br> "+ attrs.inspect + " #{success}"
	    
	    respond_to do |format|
	      if success
	        format.html { 
	        	#flash[:success] = "Saved."
	        	redirect_to @scope }
	        format.json { head :no_content }
	      else
	        format.html { 
	        	#flash[:error] = "Not saved"
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


	private

		def update_scope(scope, attr_hash)
			# scope is a Scope
			# attr_hash is a hash with
			# -- scope-level values below
			# nested arrays channels -> filters -> values

			scope.name =  attr_hash["name"]
			scope.symbol =  attr_hash["symbol"]
			scope.description = attr_hash["description"]

			if scope.valid?
				
				alert = ""

				new_channels = attr_hash["channels"].map do |c|

					# has to return array of ScopeChannels
					this_c = ScopeChannel.new
					
					c.map do |f|
						# has to return array of ScopeFilters
						this_f = ScopeFilter.new(field: f["field"])

						f["values"].map do |v|
							# has to return array of ScopeFilterValues
							this_v = ScopeFilterValue.new(value: v)
							if !this_v.valid?
								alert += this_v.errors
							end
							this_f.scope_filter_values << this_v
						end

						if !this_f.valid?
							alert += this_f.errors.full_messages.join ", "
						end
						
						this_c.scope_filters << this_f
					end

					if !this_c.valid?
						alert += this_c.errors.full_messages.join ", "
					end

					alert += "#{this_c.inspect} #{!this_c.blank?} <br>"
					this_c

				end

				# flash[:alert] = alert if alert != ""

				scope.scope_channels = []
				
				new_channels.each do |nc|
					scope.scope_channels << nc
				end


				if scope.save
					flash[:success] = 'Saved scope and channels'
					return true
				else
					flash[:error] = "#{alert} <br> #{scope.errors.full_messages.join "," }"
					flash[:notice] = 'Saved scope, not channels'
					return false
				end

			else
				flash[:notice] = "Couldn't update scope attributes <br> #{scope_level_values.inspect}"
				false
			end
		end


end
