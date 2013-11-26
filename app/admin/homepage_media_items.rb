ActiveAdmin.register HomepageMediaItem do
  menu :parent => "Media"

  index do
    column :id
    # Adds image thumbnails and download links.
    column "Files" do |home_media_item|
      if home_media_item.home_media_content_type == 'image/png'
        link_to(image_tag(home_media_item.home_media.url, :height => '100'), admin_homepage_media_item_path(home_media_item))
      elsif home_media_item.home_media_content_type == 'image/jpeg'
        link_to(image_tag(home_media_item.home_media.url, :height => '100'), admin_homepage_media_item_path(home_media_item))
      elsif home_media_item.home_media_content_type == 'image/gif'
        link_to(image_tag(home_media_item.home_media.url, :height => '100'), admin_homepage_media_item_path(home_media_item))
      elsif home_media_item.home_media_content_type.nil?
        link_to('')
      else
        link_to(home_media_item.home_media_file_name, home_media_item.home_media.url)
      end
    end
    # Makes url a hyperlink
    column "Url", :url do |home_media_item|
      if home_media_item.is_youtube(home_media_item.url)
        link_to(home_media_item.url, home_media_item.url)
      end
    end
    column :order
    column :published
    column :banner_title
    column :banner_text
    column :banner_link_text
    column "Banner Link", :banner_link do |home_media_item|
      link_to(home_media_item.banner_link)
    end
    column :home_media_file_name
    column :home_media_content_type
    column :home_media_file_size
    column :created_at
    column :updated_at
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Home Media" do
      f.input :home_media, :as => :file
      f.input :url, :label => "Media Url"
      f.input :banner_title, :hint => "Appears above other text"
      f.input :banner_text, :hint => "Appears to left of link"
      f.input :banner_link
      f.input :banner_link_text, :hint => "This replaces the link url with text"
      f.input :order
      f.input :published
    end
    f.buttons
  end

end
