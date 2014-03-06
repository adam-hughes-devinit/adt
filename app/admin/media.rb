ActiveAdmin.register Media do
  menu :parent => "Content"

  index do
    column :id
    column :media_type
    column :name
    column :url
    column :image_url
    column :publisher
    column :date
    column :teaser
    column :created_at
    column :updated_at
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Media" do
      f.input :media_type
      f.input :name
      f.input :url, :hint => "Can use internal links as well. Use Universal Media Items to upload internal media. Appropriate link is provided on that admin page."
      f.input :image_url, :hint => "Can use internal links as well. Use Universal Media Items to upload internal media. Appropriate link is provided on that admin page."
      f.input :publisher
      f.input :date, :hint => "Must be included. Used for ordering on the page."
      f.input :teaser, as: :html_editor, :hint => "Only used for Other Publications"
    end
    f.buttons
  end
  
end
