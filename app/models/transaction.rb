class Transaction < ActiveRecord::Base
  attr_accessible :currency_id, :usd_defl, :value, :project_id, :currency, :usd_current
  before_save :round_value
  has_paper_trail
  
 
  belongs_to :currency
  belongs_to :project

  def round_value
  	self.value = self.value.round(2)
  	self.usd_defl = self.usd_defl.round(2)
  	self.usd_current = self.usd_current.round(2)
  end

end
