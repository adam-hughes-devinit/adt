class ExchangeRate < ActiveRecord::Base
  belongs_to :from_currency, :class_name => "Currency"
  belongs_to :to_currency, :class_name => "Currency"
  attr_accessible :rate, :year, :from_currency_id, :to_currency_id

  validates :rate, presence: true
  validates :year, presence: true
  validates :from_currency_id, presence: true
  validates :to_currency_id, presence: true

  validates :year, :uniqueness => {:scope => [:from_currency_id, :to_currency_id]}


end
