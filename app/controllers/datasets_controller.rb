class DatasetsController < ApplicationController

	def index
		redirect_to( Content.find_by_name("downloads") || "/")
	end

	def show
		this_dataset_location = Rails.root.join('public', 'static_datasets') + "aiddata_china_#{params[:id].gsub(/\./, "_")}.xlsx"
		send_file this_dataset_location
	end

end
