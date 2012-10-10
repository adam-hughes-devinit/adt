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


end
