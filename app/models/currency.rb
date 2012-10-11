class Currency < ActiveRecord::Base
  attr_accessible :iso3, :name

  validates :name, presence: true
  validates :iso3, presence: true
  
  has_many :transactions
  has_many :projects, through: :transactions
end
