class Media < ActiveRecord::Base
  attr_accessible :date, :image_url, :media_type_id, :media_type, :name, :publisher, :teaser, :url

  belongs_to :media_type

  validates_presence_of :date, :image_url, :media_type, :name, :publisher, :teaser, :url
  validates_uniqueness_of :name
end
