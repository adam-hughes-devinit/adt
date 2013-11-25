ActiveAdmin.register Organization do
  menu :parent => "Organizations"

  index do
    column :id
    column :name
    column :description
    column :organization_type
    column :created_at
    column :updated_at
    default_actions
  end
  
end
