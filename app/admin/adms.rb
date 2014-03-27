ActiveAdmin.register Adm do
  menu :parent => "Geocoding"

  #index do
  #  column "Geocode" do |adm|
  #    adm.geocodes.map{ |p| p.name }.join(' ')
  #  end
  #end

  index do
    column :id
    column :name
    column :code
    column :level
    column :created_at
    column :updated_at
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :code
      f.input :level
      #f.input :the_geom
    end
    f.buttons
  end
  
end
