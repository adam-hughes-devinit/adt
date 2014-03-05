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
      if !media_item.blank?
        link_to(media_item.url, media_item.url)
      end
    end
    column :downloadable
    column :publish
    column :featured
    column :on_homepage
    column :homepage_text
    column :download_text
    column :media_source_type
    column :media_file_name
    column :media_content_type
    column "Media File Size", :media_file_size do |media_item|
      number_to_human_size(media_item.media_file_size)
    end
    column :created_at
    column :updated_at
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Media Item" do
      f.input :project, :input_html => { :disabled => true }
      f.input :media, :as => :file, :input_html => { :disabled => true }
      f.input :media_file_name, :input_html => { :disabled => true }
      f.input :url, :input_html => { :disabled => true }
      f.input :media_source_type
      f.input :downloadable, :hint => "Makes file downloadable on project page"
      f.input :publish, :hint => "Warning: Only publish images and youtube videos"
      f.input :featured, :hint => "First image to appear in media viewer on project page"
      f.input :on_homepage, :hint => "Warning: Only publish images and youtube videos on homepage"
      f.input :homepage_text
      f.input :download_text
    end
    f.buttons
  end


  
end
