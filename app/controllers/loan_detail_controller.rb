class LoanDetailController < ApplicationController  

	def new 
	  @loanDetail = LoanDetail.new
	end

	
	def update
=begin
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
    
=end
	end
	
	def edit
		render "edit"
	end
	
	def show
		render 'show'
	end
	
	
end
