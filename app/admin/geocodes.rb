ActiveAdmin.register Geocode do
  menu :parent => "Geocoding"

  index do
    column :id
    column :project
    column :geo_name
    column :precision_id
    column :adm
    column :geo_upload_id
    column :created_at
    column :updated_at
    default_actions
  end
  
end
