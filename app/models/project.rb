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
   
  has_many :comments, dependent: :destroy
  accepts_nested_attributes_for :comments, allow_destroy: true

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
  def donor_name 
    donor ? donor.name : nil
  end

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
  def recipient_condensed
    country_name.count > 1 ? "Africa, regional" : country_name[0]
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
    string :id # only for searching

    text :title
    string :title

    text :description
    text :capacity
    text :sector_comment
    
    text :year
    string :year

    text :donor_name

    text :comments do 
      comments.map do |c|
        ["#{c.name}",
        "#{c.content}"]
      end
    end

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
    string :recipient_condensed
    string :active_string 
    string :is_commercial_string
  end

  def self.to_csv
    row_data = all.map do |project|
        sources = {}
        sources[:all] = project.sources.map{|s| "#{s.url} #{s.source_type ? ", "+s.source_type.name : ""}#{s.document_type ? ", "+s.document_type.name : '' }" }
        sources[:factiva] = project.sources.map do |s| 
          if s.source_type = SourceType.find_by_name("Factiva")
            "#{s.url} #{s.source_type ? ", "+s.source_type.name : ""}#{s.document_type ? ", "+s.document_type.name : '' }"
          end
        end

        agencies = {}
        ["Funding", "Implementing"].map do |type|
          agencies[type.to_sym] = project.participating_organizations.where("role_id = #{Role.find_by_name(type).id}").map do |a| 
            if a.organization 
              "#{a.organization.name}#{a.organization.organization_type ? ", " + a.organization.organization_type.name : ''}"
            end
          end
        end
        ["Donor", "Recipient", "Other"].map do |origin|
          agencies[origin.to_sym] = project.participating_organizations.where("origin_id = #{Origin.find_by_name(origin).id}").map do |a| 
            if a.organization 
              "#{a.organization.name}#{a.organization.organization_type ? ", " + a.organization.organization_type.name : ''}"
            end
          end
        end

        row =
          ["#{project.id}", "#{project.donor_name}", "#{project.title}", "#{project.year}", "#{project.description}",
          "#{project.sector_name}", "#{project.sector_comment}", "#{project.status_name}", "not_implemented", "#{project.flow_type_name}",
          "#{project.tied_name}", "not_implemented", "#{project.country_name.join(", ")}", "#{sources[:all].join("; ")}", "#{sources[:all].count}",
          "#{agencies[:Funding].join('; ')}", "#{agencies[:Implementing].join("; ")}",
          "#{agencies[:Donor].join("; ")}", "#{agencies[:Donor].count}", "#{agencies[:Recipient].join('; ')}", "#{agencies[:Recipient].count}",
          "#{project.verified_name}", "not_implemented", "#{project.oda_like_name}", "not_implemented", "#{project.active_string}", "not_implemented",
          "#{sources[:factiva].join("; ")}", "not_implemented", "not_implemented", "#{project.usd_2009}",
          "#{project.start_actual ? project.start_actual.strftime("%d %B %Y") : ''}", "#{project.start_planned ?  project.start_planned.strftime("%d %B %Y") : ''}", 
          "#{project.end_actual ? project.end_actual.strftime("%d %B %Y") : ''}", "#{project.end_planned ? project.end_planned.strftime("%d %B %Y"): '' }",
          "#{project.country_name.count}", "#{project.recipient_condensed}", "#{project.is_commercial_string}", "not_implemented"  
          ]
      end

    CSV.generate do |csv|
      csv << 
      # \uFEFF is a dumb hack for UTF-8 encoding in excel
      ["\uFEFFproject_id", "donor", "title", "year", "description",
        "sector", "sector_comment", "status", "status_code", "flow", 
        "tied", "tied_code", "all recipients", "sources", "sources_count", 
         "funding_agency", "implementing_agency", 
         "donor_agency", "donor_agency_count", "recipient_agencies", "recipient_agencies_count",
         "verified", "verified_code", "flow_class", "flow_class_code", "active", "active_code", 
         "factiva_sources", "amount", "currency", "usd_defl",
         "start_actual", "start_planned", 
         "end_actual", "end_planned",
         "recipient_count", "recipient_condensed", "is_commercial", "is_commercial_code"]
      row_data.each do |row|
        csv << row
      end
    end
  end


end
