class LoanType < ActiveRecord::Base
  attr_accessible :description, :id, :name
  has_paper_trail
  default_scope order: "name"

  has_many :loan_details
  has_many :projects, through: :loan_details
end
