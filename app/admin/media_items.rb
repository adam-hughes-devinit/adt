ActiveAdmin.register MediaItem do
  index do
    column :id
    column :project
    column "Image" do |media_item|
      if media_item.media_content_type == 'image/png'
        link_to(image_tag(media_item.media.url(:thumb), :height => '100'), admin_media_item_path(media_item))
      elsif media_item.media_content_type == 'image/jpeg'
        link_to(image_tag(media_item.media.url(:thumb), :height => '100'), admin_media_item_path(media_item))
      elsif media_item.media_content_type == 'image/gif'
        link_to(image_tag(media_item.media.url(:thumb), :height => '100'), admin_media_item_path(media_item))
      elsif media_item.media_content_type == 'application/pdf'
        link_to(media_item.media_file_name, media_item.media.url)
      end
    end
    column :media_file_name

    column :media_content_type
    column :media_file_size
    column :url
    column :downloadable
    column :publish
    column :created_at
    column :updated_at
    default_actions
  end


  
end
