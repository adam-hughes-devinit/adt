class MediaItemType < ActiveRecord::Base
  attr_accessible :name

  has_many :media_item
  has_many :homepage_media_item
end
