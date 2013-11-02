class Deflator < ActiveRecord::Base
  belongs_to :country
  attr_accessible :value, :year, :country_id

  validates :value, presence: true
  validates :year, presence: true
  validates :country_id, presence: true
end
