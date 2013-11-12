ActiveAdmin.register ExchangeRate do
  menu :parent => "Financial"

  index do
    column :id
    column :from_currency
    column :to_currency
    column :year
    column :rate
    column :created_at
    column :updated_at
    default_actions
  end

end
