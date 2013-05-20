class FlowClassesController < ApplicationController  

	def new 
	end
	
	def update
		get_flow_class_from_url
		
		respond_to do |format|
      if @flow_class.update_attributes(params[:flow_class])
        format.html { redirect_to "/projects/#{@flow_class.project_id}/flow_class" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @flow_class.errors, status: :unprocessable_entity }
      end
    end
    
	end
	
	def edit
		get_flow_class_from_url
		render "edit"
	end
	
	def show
		get_flow_class_from_url
		render 'show'
	end
	
	private
		def get_flow_class_from_url
			@flow_class = FlowClass.find_or_create_by_project_id(params[:project_id])
			@project = Project.find(@flow_class.project_id)
		end
	
end
