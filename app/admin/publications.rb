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
      f.input :url, :hint => "Can use internal links as well. Use Universal Media Items to upload internal media. Appropriate link is provided in that admin page."
      f.input :date, :hint => "Must be included for AidData and Affiliated publications"
      f.input :category
      f.input :location
      f.input :publisher
      f.input :description, as: :html_editor, :hint => "Only used for Other Publications"
    end
    f.buttons
  end
  
end
