class MediaItem < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  attr_accessible :publish, :media, :user_id

  has_attached_file :media, :styles => { :medium => "300x300>", :thumb => "100x100>" }

end
