class Project < ActiveRecord::Base
  attr_accessible :title, :active, :capacity, :description, :year,
  :start_actual, :start_planned, :end_actual, :end_planned, :sector_comment, 
  :is_commercial, 
  # belongs_to fields
  :status, :verified, :tied, :flow_type, :oda_like, :sector,
  #convoluted fields
  :donor, :owner, 
  :transactions, :transactions_attributes,
  :geopoliticals, :geopoliticals_attributes,
  :participating_organizations, :participating_organizations_attributes,
  :contacts, :contacts_attributes,
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


  # project accessories
  has_many :geopoliticals, dependent: :destroy
  accepts_nested_attributes_for :geopoliticals, allow_destroy: true

  has_many :transactions, dependent: :destroy
  accepts_nested_attributes_for :transactions, allow_destroy: true
  
  has_many :contacts, dependent: :destroy  
  accepts_nested_attributes_for :contacts, allow_destroy: true

  has_many :sources, dependent: :destroy
  accepts_nested_attributes_for :sources, allow_destroy: true

  has_many :participating_organizations, dependent: :destroy
  accepts_nested_attributes_for :participating_organizations, allow_destroy: true
  
  # has_many :identifiers, dependent: :destroy
  # has_many :classifications, dependent: :destroy
  # has_many :followers, dependent: :destroy
  

end
