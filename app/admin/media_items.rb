ActiveAdmin.register MediaItem do
  menu :parent => "Media"

  index do
    column :id
    column :project
     # Adds image thumbnails and download links.
    column "Files" do |media_item|
      if media_item.media_content_type == 'image/png'
        link_to(image_tag(media_item.media.url, :height => '100'), admin_media_item_path(media_item))
      elsif media_item.media_content_type == 'image/jpeg'
        link_to(image_tag(media_item.media.url, :height => '100'), admin_media_item_path(media_item))
      elsif media_item.media_content_type == 'image/gif'
        link_to(image_tag(media_item.media.url, :height => '100'), admin_media_item_path(media_item))
      elsif media_item.media_content_type.nil?
        link_to('')
      else
        link_to(media_item.media_file_name, media_item.media.url)
      end
    end
     # Makes url a hyperlink
    column "Url", :url do |media_item|
      if media_item.media_item_type.name == 'youtube'
        link_to(media_item.url, media_item.url)
      end
    end
    column :media_item_type
    column :downloadable
    column :publish
    column :featured
    column :on_homepage
    column :homepage_text
    column :download_text
    column :media_source_type
    column :media_file_name
    column :media_content_type
    column :media_file_size
    column :created_at
    column :updated_at
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Media Item" do
      f.input :project
      f.input :media_source_type
      f.input :url
      f.input :media_item_type
      f.input :downloadable
      f.input :publish
      f.input :featured
      f.input :on_homepage
      f.input :homepage_text
      f.input :download_text
    end
    f.buttons
  end


  
end
