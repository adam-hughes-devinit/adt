class Project < ActiveRecord::Base
  attr_accessible :title, :active, :capacity, :description, :year,
  :start_actual, :start_planned, :end_actual, :end_planned, :sector_comment, 
  :is_commercial, 
  # belongs_to fields
  :status, :verified, :tied, :flow_type, :oda_like, :sector,
  #convoluted fields
  :donor, :owner,
  # hidden fields
  :verified_id, :sector_id, :tied_id, :flow_type_id, 
  :oda_like_id, :status_id, 
  :donor_id, :owner_id



  validates :title, presence: true

  belongs_to :status
  belongs_to :verified
  belongs_to :tied
  belongs_to :flow_type
  belongs_to :oda_like  
  belongs_to :sector

  belongs_to :donor, class_name: "Country"
  belongs_to :owner, class_name: "Organization"

  



  # has_many :geopoliticals
  # has_many :transactions
  # has_many :contacts
  # has_many :documents
  # has_many :participating_organizations
  # has_many :identifiers
  # has_many :classifications
  # has_many :followers


end
