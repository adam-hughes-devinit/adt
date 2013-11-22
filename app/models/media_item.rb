class MediaItem < ActiveRecord::Base

  belongs_to :project
  belongs_to :user
  attr_accessible :project_id, :publish, :media, :user_id, :downloadable, :url, :media_type, :featured,
                  :homepage_text, :download_text,
                  :media_file_name, :media_content_type, :media_file_size, :media_updated_at

  validates_presence_of :url, :unless => :media?
  validates_presence_of :media, :unless => :url?
  validates_presence_of :homepage_text, :if => :publish
  validates_presence_of :download_text, :if => :downloadable


  # for paperclip
  has_attached_file :media, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  def youtube_embed(youtube_url)
    if youtube_url[/youtu\.be\/([^\?]*)/]
      youtube_id = $1
    else
      # Regex from # http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
      youtube_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
      youtube_id = $5
    end

    %Q{<iframe title="YouTube video player" width="540" height="329" src="http://www.youtube.com/embed/#{ youtube_id }" frameborder="0" allowfullscreen></iframe>}
  end


end
