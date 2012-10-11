class Currency < ActiveRecord::Base
  attr_accessible :iso3, :name

  validates :name, presence: true, uniqueness: true
  validates :iso3, presence: true, uniqueness: true
  
  has_many :transactions
  has_many :projects, through: :transactions
end
