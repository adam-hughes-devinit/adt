class MediaItem < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  attr_accessible :project_id, :publish, :media, :user_id, :downloadable, :url, :embed_code,
  :media_file_name, :media_content_type, :media_file_size, :media_updated_at

  has_attached_file :media, :styles => { :large => "540x500>", :medium => "300x300>", :thumb => "100x100>" }

end
