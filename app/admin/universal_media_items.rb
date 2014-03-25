ActiveAdmin.register UniversalMediaItem do

  menu :parent => "Content"

  index do
    column :id
    # Adds image thumbnails and download links.
    column "Files" do |media_item|
      if media_item.media_content_type == 'image/png'
        link_to(image_tag(media_item.media.url, :height => '100'), admin_universal_media_item_path(media_item))
      elsif media_item.media_content_type == 'image/jpeg'
        link_to(image_tag(media_item.media.url, :height => '100'), admin_universal_media_item_path(media_item))
      elsif media_item.media_content_type == 'image/gif'
        link_to(image_tag(media_item.media.url, :height => '100'), admin_universal_media_item_path(media_item))
      elsif media_item.media_content_type.nil?
        link_to('')
      else
        link_to(media_item.media_file_name, media_item.media.url)
      end
    end
    column "Url Path" do |media_item|
      link_to(media_item.media.url, media_item.media.url)
end
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
      f.input :media, :as => :file
    end
    f.buttons
  end


end
