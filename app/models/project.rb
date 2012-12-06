class Project < ActiveRecord::Base
  attr_accessible :title, :active, :capacity, :description, :year,
  :start_actual, :start_planned, :end_actual, :end_planned, :sector_comment,
  :cache!, :cache_text, :cache_one!,
  :is_commercial, :media_id, 
  :year_uncertain, :debt_uncertain, :line_of_credit, :crs_sector, :is_cofinanced,
  # belongs_to fields
  :status, :verified, :tied, :flow_type, :oda_like, :sector,
  #convoluted fields
  :donor, :owner, 
  :transactions, :transactions_attributes,
  :geopoliticals, :geopoliticals_attributes,
  :participating_organizations, :participating_organizations_attributes,
  :contacts, :contacts_attributes,
  :sources, :sources_attributes,
  # for version control
  :accessories, :iteration,
  # hidden fields
  :verified_id, :sector_id, :tied_id, :flow_type_id, :oda_like_id, :status_id,
  :donor_id, :owner_id
  
  before_save :set_verified_to_raw_if_null
  # before_save :deflate_values MOVED TO TRANSACTION MODEL
  after_save :cache!
  # before_save :increment_iteration MOVED TO FORM
  
  def increment_iteration # DUH, version was already taken by paper_trail
  	iteration ||= 0
		iteration += 1
  end

  has_many :comments, dependent: :destroy
  accepts_nested_attributes_for :comments, allow_destroy: true


  has_paper_trail(meta: {accessories: :accessories})
  
	
	def accessories
		{transaction: transactions.each(&:attributes), 
		 source: sources.each(&:attributes), 
		 participating_organization: participating_organizations.each(&:attributes),
		 contact: contacts.each(&:attributes),
		 geopolitical: geopoliticals.each(&:attributes)
		 }.to_json
	end
	
	
  #validates :title, presence: true

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

  def year_uncertain_string
    year_uncertain? ? "Year Uncertain" : "Year Certain"
  end

  def debt_uncertain_string
    debt_uncertain ? "Debt Relief Uncertain" : "Not Uncertain"
  end

  def line_of_credit_string
    line_of_credit ? "Line of Credit" : "Not Line of Credit"
  end
  
  def is_cofinanced_string
  	is_cofinanced ? "Cofinanced" : "Not Cofinanced"
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
    sum > 0 ? sum : nil
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
    float :usd_2009

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
          if g
            ["#{g.subnational}",
             "#{g.recipient ? g.recipient.name : ''}",
             "#{g.recipient ? g.recipient.iso3 : '' }"]
        end
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
    string :line_of_credit_string
    string :debt_uncertain_string
    string :year_uncertain_string
    string :is_cofinanced_string
    string :crs_sector
    string :recipient_iso2 do
      if geopoliticals.count > 1
        'Africa, regional' 
      elsif geopoliticals.count == 1 && geopoliticals[0].recipient
        geopoliticals[0].recipient.iso2 
      else
        'Unset'
      end
    end

  end

	
	def cache!
		if CACHE_ONE
			cached_record = Cache.find_or_create_by_id(id)
			cached_record.skip_cache_all = false
			cached_record.update_attribute(:text, cache_text)
		end
	end
	
	def cache_one!
		if CACHE_ONE
			cached_record = Cache.find_or_create_by_id(id)
			cached_record.skip_cache_all = true
			cached_record.update_attribute(:text, cache_text)
		end
	end
	
	def cache_text
    project_sources = {}
    project_sources[:all] = sources.map{|s| "#{s.url} #{s.source_type ? ", "+s.source_type.name : ""}#{s.document_type ? ", "+s.document_type.name : '' }" }
    project_sources[:factiva] = sources.map do |s| 
      if s.source_type = SourceType.find_by_name("Factiva")
        "#{s.url} #{s.source_type ? ", "+s.source_type.name : ""}#{s.document_type ? ", "+s.document_type.name : '' }"
      end
    end

    project_agencies = {}
    ["Funding", "Implementing"].map do |type|
    	project_agencies[type.to_sym] = (
    	if Role.find_by_name(type)
		    participating_organizations.where("role_id = #{Role.find_by_name(type).id}").map do |a| 
		      if a.organization 
		        "#{a.organization.name}#{a.organization.organization_type ? ", " + a.organization.organization_type.name : ''}"
		      end
		    end
		  else
		  	[]
		  end
		  )
    end
    ["Donor", "Recipient", "Other"].map do |origin|
    	project_agencies[origin.to_sym] = (
		  if Origin.find_by_name(origin)
				   participating_organizations.where("origin_id = #{Origin.find_by_name(origin).id}").map do |a| 
				    if a.organization 
				      "#{a.organization.name}#{a.organization.organization_type ? ", " + a.organization.organization_type.name : ''}"
				    end
				  end
			else 
				[]
			end
			)
    end
    
    cached_recipients = []
    geopoliticals.each {|g| g.recipient ? cached_recipients.push(g.recipient) : nil }	
    
    cache_text = "\"#{id}\",\"#{donor_name}\",\"#{title}\",\"#{year}\",\"#{year_uncertain}\"," +
    "\"#{description}\",\"#{sector_name}\",\"#{sector_comment}\",\"#{crs_sector}\",\"#{status_name}\"," +
    "\"#{status ? status.code : ''}\",\"#{flow_type_name}\"," + 
     # \"#{tied_name}\",\"#{tied ? tied.code : '' }\"," +  # Maybe we'll need this again.
    "\"#{country_name.join(", ")}\",\"#{project_sources[:all].join("; ")}\",\"#{project_sources[:all].count}\"," +
    "\"#{project_agencies[:Funding].join('; ')}\",\"#{project_agencies[:Implementing].join("; ")}\","+ 
    "\"#{project_agencies[:Donor].join("; ")}\",\"#{project_agencies[:Donor].any? ? project_agencies[:Donor].count : ''}\"," +
    "\"#{project_agencies[:Recipient].join('; ')}\",\"#{project_agencies[:Recipient].any? ? project_agencies[:Recipient].count : ''}\"," +
    "\"#{verified_name}\",\"#{verified ? verified.code : '' }\",\"#{oda_like_name}\",\"#{oda_like ? oda_like.code : '' }\","+ 
    "\"#{active_string}\",\"#{active ? 1 : 2}\",\"#{project_sources[:factiva].join("; ")}\"," +
    "\"#{transactions.map{|t| t.value}.join("; ")}\",\"#{transactions.map{|t| t.currency ? t.currency.iso3 : '' }.join("; ")}\","+ 
    "\"#{transactions.map{|t| t.deflator}.join("; ")}\",\"#{transactions.map{|t| t.exchange_rate}.join("; ")}\",\"#{usd_2009}\"," +
    "\"#{start_actual ? start_actual.strftime("%d %B %Y") : ''}\",\"#{start_planned ?  start_planned.strftime("%d %B %Y") : ''}\"," +
    "\"#{end_actual ? end_actual.strftime("%d %B %Y") : ''}\",\"#{end_planned ? end_planned.strftime("%d %B %Y"): '' }\"," +
    "\"#{country_name.any? ? country_name.count : ''}\",\"#{recipient_condensed}\"," + 
    "\"#{cached_recipients.map(&:cow_code).join("; ")}\",\"#{cached_recipients.map(&:oecd_code).join("; ")}\"," +
    "\"#{cached_recipients.map(&:oecd_name).join("; ")}\",\"#{cached_recipients.map(&:iso3).join("; ")}\"," +
    "\"#{cached_recipients.map(&:iso2).join("; ")}\",\"#{cached_recipients.map(&:un_code).join("; ")}\"," +
    "\"#{cached_recipients.map(&:imf_code).join("; ")}\"," +
    "\"#{is_commercial_string}\",\"#{is_commercial ? 1 : 2}\",\"#{debt_uncertain}\",\"#{line_of_credit}\",\"#{is_cofinanced}\""
	end
 

   def as_json(options={})
    super(
          only: [:id,:year, :title, :active, :is_commercial, :year_uncertain, :line_of_credit, :is_cofinanced, :debt_uncertain], 
          methods: [:usd_2009, :donor_name,
                    :sector_name, :flow_type_name, :oda_like_name, :status_name, 
                    # :tied_name, 
                    :recipient_condensed
                    ],
          include: [
            {geopoliticals: {include: [recipient: {only: [:name, :iso2, :iso3, :cow_code, :oecd_code]}], only: [:percent]}},
            {transactions: {include: [currency: {only: [:name, :iso3]}], only: [:value, :usd_defl, :usd_current, :deflated_at, :deflator, :exchange_rate]}},
            {contacts: {only: [:name, :position], include: [organization: {only: [:name, :organization_type]}]}},
            {sources: {only: [:url, :date], include: [source_type: {only: [:name]}, document_type: {only:[:name]}]}},
            {participating_organizations: {only: [], include: [origin: {only: [:name]}, organization: {only: [:name, :organization_type]}, role: {only: [:name]}]}}
            ]) 
  end
  
  def history
	  [self.versions \
	    + self.transactions.map(&:versions) \
	  	+ self.sources.map(&:versions) \
	  	+ self.contacts.map(&:versions) \
	  	+ self.comments.map(&:versions) \
	  	+ self.participating_organizations.map(&:versions) \
	  	+ self.geopoliticals.map(&:versions)].flatten
	end
	
	def all_flags
		[
			self.transactions.map(&:flags) + 
			self.geopoliticals.map(&:flags) +
			self.sources.map(&:flags) +
			self.contacts.map(&:flags) +
			self.participating_organizations.map(&:flags) +
			self.flags
		].flatten
	end
	
	def flags
		Flag.where("flaggable_type not in(?) and flaggable_id= ?",ApplicationHelper::PROJECT_ACCESSORY_OBJECTS, id)
	end
	
	def set_verified_to_raw_if_null
		self.verified = Verified.find_by_name("Raw") if verified.blank?
	end
end
