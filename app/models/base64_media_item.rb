class Base64MediaItem < ActiveRecord::Base
  attr_accessible :media

  has_attached_file :media
  has_one :comment
  #do_not_validate_attachment_file_type :media  #uncomment if upgrade paperclip to 4.1

end