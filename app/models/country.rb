class Country < ActiveRecord::Base
  
  attr_accessible :cow_code, :iso2, :iso3, :name,
   :oecd_code, :oecd_name, :aiddata_code, :un_code, :imf_code

  validates :name, presence: true
  #validates :iso2, presence: true, uniqueness: true, length: {maximum: 2}
  #validates :iso3, presence: true, uniqueness: true, length: {maximum: 3}
  has_many :projects_as_donor, foreign_key: "donor_id", class_name: "Project"
  has_many :geopoliticals, foreign_key: "recipient_id"
  has_many :projects_as_recipient, through: :geopoliticals, foreign_key: "recipient_id", source: :project

  def projects
  	self.projects_as_recipient + self.projects_as_donor
  end


end
 