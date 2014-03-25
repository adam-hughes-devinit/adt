class LoanDetail < ActiveRecord::Base
  attr_accessible :project_id, :project, 
  	:loan_type_id, :loan_type,
  	:grace_period, :grant_element, :maturity,
    :interest_rate

  before_save :get_grant_element!

  after_save :validate_flow_class

  has_paper_trail
  
  belongs_to :project
  belongs_to :loan_type

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

   # If grant element is above 25% and intent is Development, flow_class is set to be ODA-LIKE automatically
  def validate_flow_class
    if !self.grant_element.nil?
      if self.grant_element > 25
        if (Intent.find_by_id(self.project.intent_id).name == 'Development')
          flow_class = FlowClass.find_by_project_id(self.project_id)
          if !flow_class.oda_like_master_id.nil?
            flow_class.oda_like_master_id = 2 # Oda-like
            flow_class.save
          end
        end
      end
    end
  end

end
