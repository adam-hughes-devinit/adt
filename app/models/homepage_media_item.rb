class HomepageMediaItem < ActiveRecord::Base
  belongs_to :media_item_type
  attr_accessible :banner_link, :banner_text, :order, :published, :url, :home_media, :media_item_type_id

  has_attached_file :home_media, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  validates :media_item_type, :presence => true
  validates_presence_of :url, :unless => :home_media?
  validates_presence_of :home_media, :unless => :url?
  validates_presence_of :order, :if => :published
  validates_presence_of :banner_text, :if => :published
  validates_presence_of :banner_text, :if => :banner_link

  def youtube_embed(youtube_url,height,width)
    if youtube_url[/youtu\.be\/([^\?]*)/]
      youtube_id = $1
    else
      # Regex from # http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
      youtube_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
      youtube_id = $5
    end

    %Q{<iframe title="YouTube video player" width="#{ width }" height="#{ height }" src="http://www.youtube.com/embed/#{ youtube_id }" frameborder="0" allowfullscreen></iframe>}
  end
end
