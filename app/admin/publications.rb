ActiveAdmin.register Publication do
  menu :parent => "Content"

  index do
    column :id
    column :publication_type
    column :name
    column :author
    column :url
    column :date
    column :category
    column :location
    column :publisher
    column :description
    column :created_at
    column :updated_at
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Publication" do
      f.input :publication_type
      f.input :name
      f.input :author
      f.input :url
      f.input :date
      f.input :category
      f.input :location
      f.input :publisher
      f.input :description, as: :html_editor
    end
    f.buttons
  end
  
end
