class MediaItem < ActiveRecord::Base
  belongs_to :project
  attr_accessible :publish, :media

  has_attached_file :media, :styles => { :medium => "300x300>", :thumb => "100x100>" }

end
