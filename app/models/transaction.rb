class Transaction < ActiveRecord::Base
  attr_accessible :currency_id, :usd_defl, :value, :project_id, :currency
  has_paper_trail
  
 
  belongs_to :currency
  belongs_to :project

end
