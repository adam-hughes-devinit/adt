ActiveAdmin.register Geocode do
  menu :parent => "Geocoding"

  index do
    column :id
    column :project
    column :geo_name
    column :precision
    column :adm
    column :geo_upload
    column :created_at
    column :updated_at
    default_actions
  end
  
end
