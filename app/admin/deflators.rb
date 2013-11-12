ActiveAdmin.register Deflator do
  menu :parent => "Financial"

  index do
    column :id
    column :country
    column :year
    column :value
    column :created_at
    column :updated_at
    default_actions
  end
end
