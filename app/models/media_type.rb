class MediaType < ActiveRecord::Base
  attr_accessible :name

  has_many :media

  validates_presence_of :name
  validates_uniqueness_of :name
end
