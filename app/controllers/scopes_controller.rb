class ScopesController < ApplicationController

	def index
		#render 'scopes/index'
		respond_to do |format|
	      format.html {}
	      format.json { render json: SCOPES }
	    end
	end

	def new
		@scope = Scope.new
		@scope.scope_requirements << ScopeRequirement.new
	end

	def offset
		if offset = params[:offset].to_i
			@scope = SCOPES[offset]
			render json: @scope
		else
			redirect_to 'scopes_index'
		end
	end
end
