ActiveAdmin.register GeoUpload do
  actions :all, :except => [:new]

  menu :parent => "Geocoding"

  action_item :only => :index do
    link_to 'Upload CSV', :action => 'upload_csv'
  end

  collection_action :upload_csv do
    render "admin/csv/upload_csv"
  end

  controller do
     # When a geo_upload is deleted:
     # associated geocodes, unused geo_names, and unused geometries are deleted
    def destroy
      geocodes = Geocode.find_all_by_geo_upload_id(params[:id])
      geocodes.each do |geocode|
        geoname = GeoName.joins(:geocodes).where(id: geocode.geo_name_id)
        if geoname.count == 1
          GeoName.find(geocode.geo_name_id).delete
        end
        if !geocode.geometry_id.nil?
          geometry = Geometry.find(geocode.geometry_id)
          if geometry.adm_code.nil?
            geometry.delete
          end
        end
        geocode.delete
      end

      GeoUpload.find(params[:id]).delete

      redirect_to :action => 'index'
    end
  end

   # Import csv
  collection_action :import_csv, :method => :post do
    geo_upload = GeoUpload.create(csv: params[:dump][:file],
                                  record_count: 0,
                                  log_errors: 0,
                                  critical_errors: 0,
                                  status: 0
    )
    geo_upload.process_csv

    redirect_to :action => :index, :notice => "CSV imported successfully!"
  end

  index do
    id_column
    selectable_column

    column "Status", :sortable => :status do |upload|
      if upload.status == 0
        status_tag("Processing", :blue)
      elsif upload.status == 1
        status_tag("Pending", :warning)
      elsif upload.status == 2
        status_tag("Active", :ok)
      else upload.status == 3
        status_tag("Error", :error)
      end

    end

    column :record_count

    column "CSV File", :csv_file_name do |csv|
      link_to(csv.csv_file_name, csv.csv.url)
    end

    column "CSV File Size", :csv_file_size do |csv|
      number_to_human_size(csv.csv_file_size)
    end

    column "Log File", :log_file_name do |log|
      link_to(log.log_file_name, log.log.url)
    end

    column :critical_errors
    column :log_errors
    column :created_at
    column :updated_at

    actions defaults: false do |post|
      link_to 'Activate', edit_admin_geo_upload_path(post)
    end

    actions defaults: false do |post|
      link_to 'Delete', admin_geo_upload_path(post), :method => :delete,
              :confirm => 'WARNING: Deleting this record will delete all geocodes generated from this upload!'
    end
  end

  form do |f|
    f.inputs "Set Geocodes to Active" do
     f.input :status, hint: "Activating will make all geocodes from this Geo Upload viewable to the public. "
    end
    f.actions
  end


end
