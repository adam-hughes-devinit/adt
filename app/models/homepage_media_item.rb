class HomepageMediaItem < ActiveRecord::Base
  attr_accessible :banner_link, :banner_text, :banner_link_text, :banner_title,
                  :order, :published, :url, :home_media

  has_attached_file :home_media, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  validates_presence_of :url, :unless => :home_media?
  validates_presence_of :home_media, :unless => :url?
  validates_presence_of :order, :if => :published
  validates :url, :format => { :with =>  /^(http|https):\/\/www\.youtube\.com\/watch\?v=([a-zA-Z0-9_-]*)/, :message => "Must be youtube url" }, :allow_blank => true

  def youtube_embed(youtube_url,height,width)
    if youtube_url[/youtu\.be\/([^\?]*)/]
      youtube_id = $1
    else
      # Regex from # http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
      youtube_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
      youtube_id = $5
    end

    %Q{<iframe id="home_#{ self.id }" title="YouTube video player" width="#{ width }" height="#{ height }" src="http://www.youtube.com/embed/#{ youtube_id }" frameborder="0" allowfullscreen></iframe>}
  end
end
