class Currency < ActiveRecord::Base
  attr_accessible :iso3, :name
  has_paper_trail
  default_scope order: "name"	


  validates :name, presence: true
  validates :iso3, presence: true
  
  has_many :transactions
  has_many :projects, through: :transactions

end
