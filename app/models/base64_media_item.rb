class Base64MediaItem < ActiveRecord::Base
  attr_accessible :content_type, :original_filename, :media_data
  before_save :decode_base64_media

  has_attached_file :media,
    PAPERCLIP_CONFIG.merge(
    :styles => {
        :large => "500x500>",
        :medium => "320x320>",
        :thumb => "100x100>"
    })

  has_one :comment

  protected
  def decode_base64_media
    if media_data && content_type && original_filename
      decoded_data = Base64.decode64(media_data)

      data = StringIO.new(decoded_data)
      data.class_eval do
        attr_accessor :content_type, :original_filename
      end

      data.content_type = content_type
      data.original_filename = File.basename(original_filename)

      self.media = data
    end
  end
  #do_not_validate_attachment_file_type :media  #uncomment if upgrade paperclip to 4.1

end