ActiveAdmin.register MediaItem do
  index do
    column :id
    column :project
    column :media_file_name
    column :media_content_type
    column :media_file_size
    column :url
    column :embed_code
    column :downloadable
    column :publish
    column :created_at
    column :updated_at
    default_actions
  end
  
end
