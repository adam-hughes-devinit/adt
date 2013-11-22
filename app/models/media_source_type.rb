class MediaSourceType < ActiveRecord::Base
  attr_accessible :name
  has_many :media_items

  validates :name, presence: true, uniqueness: true
end
