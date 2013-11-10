ActiveAdmin.register Deflator do
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
