class Project < ActiveRecord::Base
  attr_accessible :title, :active, :capacity, :description, :year,
  :start_actual, :start_planned, :end_actual, :end_planned, :sector_comment, 
  :is_commercial, :media_id,
  # belongs_to fields
  :status, :verified, :tied, :flow_type, :oda_like, :sector,
  #convoluted fields
  :donor, :owner, 
  :transactions, :transactions_attributes,
  :geopoliticals, :geopoliticals_attributes,
  :participating_organizations, :participating_organizations_attributes,
  :contacts, :contacts_attributes,
  :sources, :sources_attributes,
  # hidden fields
  :verified_id, :sector_id, :tied_id, :flow_type_id, 
  :oda_like_id, :status_id, 
  :donor_id, :owner_id
   

  default_scope order: "year"

  has_paper_trail

  validates :title, presence: true

  # I'm adding string methods for these codes for Sunspot Facets
  belongs_to :status
  def status_name
    status.present?  ? status.name : 'Unset'
  end
  
  belongs_to :verified
  def verified_name
    verified.present? ? verified.name : 'Unset'
  end

  belongs_to :tied
  def tied_name
    tied.present? ? tied.name : 'Unset'
  end

  belongs_to :flow_type
  def flow_type_name
    unless flow_type.nil?
      flow_type.name
    else
      "Unset"
    end
  end

  belongs_to :oda_like
  def oda_like_name
    unless oda_like.nil?
      oda_like.name
    else
      "Unset"
    end
  end 

  belongs_to :sector
  def sector_name
    unless sector.nil?  
      sector.name
    else
      "Unset"
    end 
  end


  belongs_to :donor, class_name: "Country"
  belongs_to :owner, class_name: "Organization"
  def owner_name
    owner ? owner.name : nil
  end

  # for filtering
  def active_string 
    active? ? 'Active' : 'Inactive'
  end

  def is_commercial_string
    is_commercial? ? 'Commercial' : 'Not Commercial'
  end

  # project accessories
  has_many :geopoliticals, dependent: :destroy
  accepts_nested_attributes_for :geopoliticals, allow_destroy: true, :reject_if => proc { |a| a['recipient_id'].blank? }
  def country_name
      geopoliticals.map do |g|
        g.recipient ? g.recipient.name : 'Unset'
      end
  end
  has_many :transactions, dependent: :destroy
  accepts_nested_attributes_for :transactions, allow_destroy: true, :reject_if => proc { |a| a['value'].blank? }
  def usd_2009
    sum = 0
    transactions.map { |t| sum += t.usd_defl unless t.usd_defl.nil?} 
    sum
  end
  def currency_name
    transactions.map do |t| 
      t.currency ? t.currency.name : 'Unset'
    end
  end


  has_many :contacts, dependent: :destroy  
  accepts_nested_attributes_for :contacts, allow_destroy: true, :reject_if => proc { |a| a['name'].blank? && a['position'].blank? && a['organization_id'].blank?}

  has_many :sources, dependent: :destroy
  accepts_nested_attributes_for :sources, allow_destroy: true, :reject_if => proc { |a| a['url'].blank? }
  def document_type_name
    d = sources.map {|s| s.document_type.present? ? s.document_type.name : 'Unset'}
  end

  def source_type_name
    s = sources.map {|s| s.source_type.present? ? s.source_type.name : 'Unset'}
  end

  has_many :participating_organizations, dependent: :destroy
  accepts_nested_attributes_for :participating_organizations, allow_destroy: true, :reject_if => proc { |a| a['organization_id'].blank? }
  def origin_name
    participating_organizations.map {|p| p.origin.present? ? p.origin.name : 'Unset'}
  end

  def organization_type_name
    participating_organizations.map {|p| p.organization.present? && p.organization.organization_type.present? ? p.organization.organization_type.name : 'Unset'}
  end

  def role_name
    participating_organizations.map {|p| p.role.present? ? p.role.name : 'Unset'}
  end

  def organization_name
    participating_organizations.map { |p| p.organization.present? ? p.organization.name : 'Unset'}
  end


  # has_many :identifiers, dependent: :destroy
  # has_many :classifications, dependent: :destroy
  # has_many :followers, dependent: :destroy

  searchable do 
    text :title, :description, :capacity, :sector_comment

    text :geopoliticals do
        geopoliticals.map do |g| 
          ["#{g.subnational}",
           "#{g.recipient ? g.recipient.name : ''}",
           "#{g.recipient ? g.recipient.iso3 : '' }"]
        end
    end

    text :participating_organizations do
      participating_organizations.map do |o| 
        ["#{o.organization ? o.organization.name : '' }",
         "#{o.role ?  o.role.name : ''}",
         "#{o.organization && o.organization.organization_type ? o.organization.organization_type.name : ''}"] 
      end
    end

    text :sources do
      sources.map do |s| 
        ["#{s.url}",
         "#{s.source_type  ? s.source_type.name : ''}",
         "#{s.document_type ? s.document_type.name  : ''}",
         "#{s.date ? s.date.strftime('%d %B %Y') : ''}"]
       end
    end

    text :transactions do
      transactions.map do |t| 
        ["#{t.currency ? t.currency.name +  ' '+ t.currency.iso3 : ''}",
          "#{t.value}"]
      end
    end

    text :contacts do
      contacts.map do |c| 
        ["#{c.name}",
          "#{c.position}",
          "#{c.organization ? c.organization.name : ''}"]
      end
    end

    string :owner_name
    string :sector_name 
    string :flow_type_name
    string :oda_like_name
    string :verified_name
    string :tied_name
    string :status_name
    string :source_type_name, multiple: true
    string :document_type_name, multiple: true
    string :currency_name, multiple: true
    string :origin_name, multiple: true
    string :organization_type_name, multiple: true
    string :organization_name, multiple: true
    string :role_name, multiple: true
    string :country_name, multiple: true
    string :active_string 
    string :is_commercial_string
  end



end
