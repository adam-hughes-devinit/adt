class ExchangeRate < ActiveRecord::Base
  belongs_to :currency
  attr_accessible :rate, :year, :currency_id
end
