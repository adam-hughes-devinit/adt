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
      if !home_media_item.blank?
        link_to(home_media_item.url, home_media_item.url)
      end
    end
    column :order
    column :published
    column :banner_title
    column :banner_text
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
      f.input :banner_title, :hint => "Appears above banner text and is larger."
      f.input :banner_text, :hint => "To add a hyperlink to banner text: <a href='http://www.youtube.com'>link text</a>"
      f.input :order
      f.input :published
    end
    f.buttons
  end

end
