ActiveAdmin.register GeoUpload do
  menu :parent => "Geocoding"

  action_item :only => :index do
    link_to 'Upload CSV', :action => 'upload_csv'
  end

  collection_action :upload_csv do
    render "admin/csv/upload_csv"
  end

  collection_action :import_csv, :method => :post do
    n = SmarterCSV.process(params[:dump][:file].tempfile,
                           {:remove_unmapped_keys => true,
                            :key_mapping => {:geo_coding_id => :geo_code, :geo_name => :geo_name, :project_id => :project_id,
                                             :precision => :precision_id, :latitude => :latitude,  :longitude => :longitude,
                                             :location_type => :location_type }}) do |chunk|
      chunk.each do |record|
        geocode = {}
        geocode[:precision_id] = record[:precision_id]
        geocode[:project_id] = record[:project_id]
        geocode[:geo_upload_id] = params[:id]
        geo_name = {}
        geo_name[:name] = record[:geo_name]
        geo_name[:code] = record[:geo_code]
        geo_name[:latitude] = record[:latitude]
        geo_name[:longitude] = record[:longitude]
        puts record

        location_type = LocationType.find_by_name(record[:location_type])
        if !location_type.nil?
          geo_name[:location_type_id] = location_type.id
        end

        geometry = {}
        factory = RGeo::Cartesian.factory
        lonlat = factory.point(record[:longitude], record[:latitude])
        new_geometry
        if record[:precision_id] == 1  # its a point
          geometry[:the_geom] = lonlat
          new_geometry = Geometry.create ( geometry )
        end

        if record[:precision_id] == 2  # its a buffer
          # code for creating buffer from lonlat
          new_geometry = Geometry.create ( geometry )
        end

        #### Do more precision logic with adms


        geocode[:geometry_id] = new_geometry.id
        new_geo_name = GeoName.create( geo_name )
        geocode[:geo_name_id] = new_geo_name.id
        Geocode.create( geocode )
      end
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
