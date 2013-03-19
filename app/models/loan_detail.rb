class LoanDetail < ActiveRecord::Base
  attr_accessible :project_id, :project, 
  :grace_period, :grant_element, :interest_rate, 
  :loan_type_id, :loan_type, :maturity

  before_save :get_grant_element

  has_paper_trail
  
  belongs_to :project
  belongs_to :loan_type

  def get_grant_element
  	if self.project && self.maturity && self.project.usd_2009 && self.interest_rate
	  	require 'open-uri'

	  	value = self.project.usd_2009
	  	ge_query = "maturity=#{self.maturity}&value=#{value}&interest_rate=#{self.interest_rate/100}"

	  	ge_query += "&grace_period=#{self.grace_period}" if grace_period
	  	
	  	ge_root = 'http://aiddata-loan-calculator.herokuapp.com/calculate'

	    
	    p  ge_url = "#{ge_root}?#{ge_query}"
	    ge_string = open(ge_url){|io| io.read}
	    p ge_string


		ge_object = ActiveSupport::JSON.decode(ge_string)


		ge_percent = ge_object["grant_element_percent"]

		self.grant_element = (ge_percent * 100).round(2)
		self.time_calculated = Time.now
	else
		p "No grant element"
	end

  end

end
