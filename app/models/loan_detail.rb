class LoanDetail < ActiveRecord::Base
  attr_accessible :project_id, :project, 
  	:loan_type_id, :loan_type,
  	:grace_period, :grant_element, :maturity,
    :interest_rate

  #before_save :get_grant_element!

  has_paper_trail
  
  belongs_to :project
  belongs_to :loan_type

  #accepts_nested_attributes_for :loan_type

  CALCULATOR_URL = 'http://aiddata-loan-calculator.herokuapp.com/calculate'
  
  delegate :usd_2009, to: :project, prefix: true

  def get_grant_element!
  	if self.maturity && self.project_usd_2009 && self.interest_rate
	  	require 'open-uri'
  	
	  	ge_query = "maturity=#{self.maturity}&value=#{project_usd_2009}&interest_rate=#{self.interest_rate/100}"

	  	ge_query += "&grace_period=#{self.grace_period}" if grace_period
	  	

	    ge_url = "#{CALCULATOR_URL}?#{ge_query}"
	    # p "GRANT ELEMENT #{ge_url}"
	    ge_string = open(ge_url){|io| io.read}
	    
		ge_object = ActiveSupport::JSON.decode(ge_string)


		ge_percent = ge_object["grant_element_percent"]

		self.grant_element = (ge_percent * 100).round(2)
		
	else
		self.grant_element = nil
	end

	self.time_calculated = Time.now

  end

end
