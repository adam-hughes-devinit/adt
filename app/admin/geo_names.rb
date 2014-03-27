ActiveAdmin.register GeoName do
  menu :parent => "Geocoding"

  index do
    column :id
    column :name
    column :code
    column :location_type
    column :created_at
    column :updated_at
    default_actions
  end
  
end
