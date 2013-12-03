ActiveAdmin.register Person do
  menu :parent => "Content"

  index do
    column :id
    # Adds image thumbnails and download links.
    column "Avatar" do |image|
      if image.avatar_content_type == 'image/png'
        link_to(image_tag(image.avatar.url, :height => '100'), admin_person_path(image))
      elsif  image.avatar_content_type == 'image/jpeg'
        link_to(image_tag( image.avatar.url, :height => '100'), admin_person_path(image))
      elsif  image.avatar_content_type == 'image/gif'
        link_to(image_tag( image.avatar.url, :height => '100'), admin_person_path(image))
      elsif image.avatar_type_content_type.nil?
        link_to('')
      else
        link_to( image.avatar_file_name,  image.avatar.url)
      end
    end
    column :first_name
    column :last_name
    column :position
    column :title
    column :email
    column :bio
    column :current_team_member
    column :avatar_file_name
    column :avatar_content_type
    column :avatar_file_size
    column :created_at
    column :updated_at
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Person" do
      f.input :avatar, :as => :file
      f.input :avatar_file_name, :input_html => { :disabled => true }
      f.input :first_name
      f.input :last_name
      f.input :position
      f.input :title
      f.input :email
      f.input :bio, as: :html_editor
      f.input :current_team_member
    end
    f.buttons
  end
  
end
