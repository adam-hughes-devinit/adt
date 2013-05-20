class DatasetsController < ApplicationController

	def index
		redirect_to( content_by_name_path("downloads") || "/")
	end

	def show
		# dataset must be named "aiddata_china_x_y.xlsx" where x and y are version major/minor, ie 1.0 x=1, y=0
		this_dataset_location = Rails.root.join('public', 'static_datasets') + "aiddata_china_#{params[:id].gsub(/\./, "_")}.xlsx"
		send_file this_dataset_location
	end

end
