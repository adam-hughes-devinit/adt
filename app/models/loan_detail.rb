class LoanDetail < ActiveRecord::Base
  attr_accessible :project_id, :project, 
  :grace_period, :grant_element, :interest_rate, 
  :loan_type_id, :loan_type, :maturity

  has_paper_trail
  
  belongs_to :project
  belongs_to :loan_type
end
