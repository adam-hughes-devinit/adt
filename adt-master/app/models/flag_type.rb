class FlagType < ActiveRecord::Base
  attr_accessible :color, :name
  validates :name, presence: true
  has_many :flags

  has_paper_trail
end
