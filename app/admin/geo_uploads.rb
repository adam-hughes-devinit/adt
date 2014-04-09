ActiveAdmin.register GeoUpload do
  menu :parent => "Geocoding"

  action_item :only => :index do
    link_to 'Upload CSV', :action => 'upload_csv'
  end

  controller do
    def create
      @geo_upload = GeoUpload.new(params[:geo_upload])
    end
  end

  collection_action :upload_csv do
    render "admin/csv/upload_csv"
  end

  collection_action :import_csv, :method => :post do
    geo_upload = GeoUpload.new(params[:geo_upload])
    n = SmarterCSV.process(params[:dump][:file].tempfile,
                           {:chunk_size => 100, :remove_unmapped_keys => true,
                            :key_mapping => {:geo_name_id => :geo_name_id, :geo_name => :geo_name, :project_id => :project_id,
                                             :precision => :precision_id, :latitude => :latitude,  :longitude => :longitude,
                                             :location_type => :location_type }}) do |chunk|

      geo_upload = GeoUpload.csv_to_database(chunk, geo_upload)
      geo_upload.save
      #puts chunk.inspect   # we could at this point pass the chunk to a Resque worker..
    end
    redirect_to :action => :index, :notice => "CSV imported successfully!"
  end

  index do
    column :id
    column :record_count
    column :csv_file_name
    column :csv_content_type
    column "CSV File Size", :csv_file_size do |csv|
      number_to_human_size(csv.csv_file_size)
    end
    column :created_at
    column :updated_at
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "CSV" do
      f.input :csv, :as => :file
    end
    f.buttons
  end
  
end
