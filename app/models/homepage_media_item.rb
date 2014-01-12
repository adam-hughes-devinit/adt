class HomepageMediaItem < ActiveRecord::Base
  attr_accessible :banner_text, :banner_title,
                  :order, :published, :url, :home_media

  has_attached_file :home_media, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  validates_attachment :home_media,
                       :content_type => { :content_type => ["image/jpg", "image/gif", "image/png"],
                                          :message => "Must be an image (jpg, gif, png)" },
                       :size => { :in => 0..1.megabytes, :message => "must be less than 1 MB"  }

  validates_presence_of :url, :unless => :home_media?
  validates_presence_of :home_media, :unless => :url?
  validates_presence_of :order, :if => :published
  validates :url, :format => { :with =>  /^(http|https):\/\/www\.youtube\.com\/watch\?v=([a-zA-Z0-9_-]*)/,
                               :message => "Whoa there buddy. Must be a valid youtube url." },
            :allow_blank => true


  def youtube_embed(youtube_url,height,width,iframe_id)
    if youtube_url[/youtu\.be\/([^\?]*)/]
      youtube_id = $1
    else
      # Regex from # http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
      youtube_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
      youtube_id = $5
    end

    %Q{<iframe id="slide_#{ iframe_id }" title="YouTube video player" width="#{ width }" height="#{ height }" src="http://www.youtube.com/embed/#{ youtube_id }?enablejsapi=1" frameborder="0"  allowfullscreen="false"></iframe>}
  end
end
