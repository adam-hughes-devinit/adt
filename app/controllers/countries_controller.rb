class CountriesController < ApplicationController

	def index
		@countries = Country.all
	end

	def new 
		@country = Country.new
	end

	def show
		@country = Country.find_by_id(params[:id])	
	end

	def create
		@country = Country.new(params[:country])
		if @country.save
			flash[:success] = "Country saved"
			redirect_to @country
		else
			render 'new'
		end
	end

	def edit
		@country = Country.find(params[:id])
	end

	def update
	    @country =Country.find(params[:id])

	    respond_to do |format|
	      if @country.update_attributes(params[:country])
	        format.html { redirect_to @country, notice: 'Country was successfully updated.' }
	        format.json { head :no_content }
	      else
	        format.html { render action: "edit" }
	        format.json { render json: @country.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def update_all

		redirect_to 'new'
	end


end
