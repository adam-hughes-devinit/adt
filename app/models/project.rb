class Project < ActiveRecord::Base
  include ProjectCache
  include ProjectExporters
  extend  ProjectExporterHeaders
  include ActionView::Helpers::NumberHelper
  
  attr_accessible :title, :active, :capacity, :description, :year,
    :start_actual, :start_planned, :end_actual, :end_planned, :sector_comment,
    :is_commercial, :media_id, 
    :year_uncertain, :debt_uncertain, :line_of_credit,
    :is_cofinanced,
    # belongs_to fields
    :status, :verified, 
    ## :tied, :tied_id, -- removed so that it will break if it's used somewhere. 
    :flow_type, :oda_like, :sector,
    #convoluted fields
    :donor, :owner, 
    :transactions, :transactions_attributes,
    :geopoliticals, :geopoliticals_attributes,
    :participating_organizations, :participating_organizations_attributes,
    :contacts, :contacts_attributes,
    :sources, :sources_attributes,
    :flow_class_attributes,
    :loan_detail_attributes,
    # for version control
    :accessories, :iteration,
    # hidden fields
    :verified_id, :sector_id,  :flow_type_id, :oda_like_id, :status_id,
    :donor_id, :owner_id, :intent_id, :crs_sector_id,
    :last_state

  before_save :set_verified_to_raw_if_null
  # after_save :remake_scope_files
  # after_destroy :remake_scope_files

  def project_logger
    @@project_logger ||= Logger.new("#{Rails.root}/log/project.log")
  end


  def association_hash
    assoc_hash = {}
    class_name = self.class.name
    association_keys = class_name.constantize.reflections.keys
    association_keys.each do |assoc_sym|
      next if assoc_sym == :versions
      value = self.send(assoc_sym)
      ids = []
      if value.respond_to?(:map)
        ids = value.map {|item| item.id}
      else
        if value
          ids << value.id
        else
          ids << value
        end
      end
      assoc_hash[assoc_sym.to_s] = ids
    end
    assoc_hash
  end

  def attribute_hash
    att_hash = self.attributes
    att_hash.delete('last_state')
    att_hash
  end

  def full_hash
    association_hash.merge(attribute_hash)
  end

  def save_state
    self.assign_attributes({last_state: full_hash.to_yaml})
  end

  def association_changed?
    if YAML.load(last_state) == association_hash
      return false
    else
      return true
    end
  end

  def changes
    changes_hash = {}
    return changes_hash if last_state == nil
    last_hash = YAML.load(last_state)
    current_hash = full_hash
    current_hash.each_pair do |key, current_value|
      #unrelevant details
      next if key == 'updated_at' || key == 'iteration'
      if current_value != last_hash[key]
        changes_hash[key] = [last_hash[key], current_value]
      end
    end
    changes_hash
  end

  def remake_scope_files
    scope.each do |s|
      cache_files(s)
    end
  end 


  def increment_iteration # DUH, version was already taken by paper_trail
    iteration ||= 0
    iteration += 1
  end


  has_and_belongs_to_many :exports

  has_many :comments, dependent: :destroy
  accepts_nested_attributes_for :comments, allow_destroy: true


  has_paper_trail(meta: {accessories: :accessories})


  def accessories
    {transaction: transactions.each(&:attributes), 
      source: sources.each(&:attributes), 
      participating_organization: participating_organizations.each(&:attributes),
      contact: contacts.each(&:attributes),
      geopolitical: geopoliticals.each(&:attributes),
      flow_class: flow_class(&:attributes),
      loan_detail: loan_detail(&:attributes)
    }.to_json
  end

  validates :donor, presence: true

  def to_english(options={})
    exclude_title = options[:exclude_title] || false
    "#{exclude_title ? "" : "#{title}: "}" +
    "#{ usd_2009.present? && usd_2009 > 0 ? "$#{number_with_precision(usd_2009, precision: 2, delimiter: ",")}" : ""}" +
    (geopoliticals.blank? ? "" : " to #{country_name.to_sentence}" ) +
    (year.present? ? " in #{year}" : "")
  end

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

  belongs_to :intent
  def intent_name
    intent.present? ? intent.name : 'Unset'
  end

  belongs_to :flow_type
  def flow_type_name
    unless flow_type.nil?
      flow_type.name
    else
      "Unset"
    end
  end

  # 1/8/13 -- restructuring flow class             ~~~~~~~~~~~~~~~~
  #
  # Replacing oda_like with a double-code + arbitrated FlowClass

  # OLD:
  #belongs_to :oda_like

  def old_oda_like
    if oda_like_id
      OdaLike.find(oda_like_id)
    end
  end

  def oda_like_name
    unless oda_like.nil?
      oda_like.name
    else
      "Unset"
    end
  end 

  # NEW:

  def oda_like=(new_oda_like)
    # first it tries round 1, then round 2. you can't set the master this way. 
    flow_class= FlowClass.find_or_create_by_project_id(id)
    if new_oda_like
      if flow_class.oda_like_1.nil?
        flow_class.oda_like_1_id=new_oda_like.id
      else
        flow_class.oda_like_2_id=new_oda_like.id
      end
    end

    flow_class.save
  end

  def oda_like(what_is_it=false)
    if what_is_it==false
      if flow_class && best_answer = flow_class.oda_like_master || flow_class.oda_like_2 || flow_class.oda_like_1
        best_answer
      else
        nil
      end
    else
      if flow_class
        if best_answer = flow_class.oda_like_master
          answer_type = "Arbitrated"
          [best_answer, answer_type]
        elsif best_answer = flow_class.oda_like_2 || flow_class.oda_like_1
          answer_type = "Single-coded"
          [best_answer, answer_type]
        else 
          nil
        end
      else
        nil
      end
    end
  end

  ############################################################
  # Flow Class Methods
  ############################################################
  def visible_flow_class
    oda_like(true) # to return [best_answer, answer_type]
  end

  def flow_class_arbitrated
    if flow_class && flow_class.oda_like_master
      flow_class.oda_like_master.name
    else
      "None"
    end
  end

  def flow_class_1
    if flow_class && flow_class.oda_like_1
      flow_class.oda_like_1.name
    else
      "None"
    end
  end

  def flow_class_2
    if flow_class && flow_class.oda_like_2
      flow_class.oda_like_2.name
    else
      "None"
    end
  end 

  has_one :flow_class, dependent: :destroy
  accepts_nested_attributes_for :flow_class

  ####################################################
  # Loan Detail Methods
  ####################################################

  # RDM 3/25/2013 "_band" methods for searching

  has_one :loan_detail, dependent: :destroy
  accepts_nested_attributes_for :loan_detail

  def loan_type
    if loan_detail.nil?
      "Unset"
    else
      loan_detail.loan_type
    end
  end

  def loan_type_name
    if loan_detail.nil? || loan_detail.loan_type.nil?
      ""
    else
      loan_detail.loan_type.name
    end
  end

  def interest_rate
    if loan_detail.nil?
      ""
    else
      loan_detail.interest_rate
    end
  end


  def interest_rate_band
    # don't use "%" -- it screws up the search URLs
    if (!loan_detail.nil?) && (m = loan_detail.interest_rate)
      if m <= 10
        "#{m} percent"
      elsif m > 10
        ">10 percent"
      end
    else
      "(None)"
    end
  end

  def maturity
    if loan_detail.nil?
      ""
    else
      loan_detail.maturity
    end
  end

  def maturity_band
    if (!loan_detail.nil?) && (m = loan_detail.maturity)
      if m < 5
        "0 to 5 years"
      elsif m >= 5 && m <=15
        "5 to 15 years"
      elsif m > 15
        ">15 years"
      end

    else
      "(None)"
    end
  end
        

  def grace_period
    if loan_detail.nil?
      ""
    else
      loan_detail.grace_period
    end
  end

  def grace_period_band
    if (!loan_detail.nil?) && (m = loan_detail.grace_period)
      if m <= 5
        "#{m} year#{ m != 1 ? 's' : ""}"
      elsif m > 5 && m <=10
        "6 to 10 years"
      elsif m > 10
        ">10 years"
      end
    else
      "(None)"
    end
  end

  def grant_element
    if loan_detail.nil?
      ""
    else
      loan_detail.grant_element
    end
  end
  
  def grant_element_band
    if (!loan_detail.nil?) && (m = loan_detail.grant_element)
      if m < 25
        "0 to 24 percent"
      elsif m >= 100
        "100 percent"
      elsif m >= 25 && m <= 50
        "25 to 50 percent"
      elsif m < 100 && m > 50
        "51 to 99 percent"
      end
    else
      "(None)"
    end
  end

  #
  #  End restructuring
  #

  # Deprecated in favor of CrsSectors
  belongs_to :sector
  def sector_name
    unless sector.nil?  
      sector.name
    else
      "Unset"
    end 
  end

  belongs_to :crs_sector
  def crs_sector_name
    crs_sector ? crs_sector.name : nil
  end

  def crs_sector_code
    crs_sector ? crs_sector.code : nil
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
    end.sort
  end
  def recipient_condensed
    country_name.count > 1 ? "Africa, regional" : country_name[0]
  end
  def number_of_recipients
    country_name.length
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

  # These used to be done inside the search block, now that FACETS are integrated, 
  # I had to move the code down here.
  def flagged 
     all_flags.map(&:name)
  end

  def commented
    comments.present? ? "Has Comments" : nil
  end

  def recipient_iso2
    self.geopoliticals.map { |g| g.recipient ? g.recipient.iso2 : "Unset" }
  end

  searchable do 

    integer :id # for sorting
    double :usd_2009 # for sorting
    string :title # for sorting
    string :donor_name # for sorting
    string :recipient_condensed # fir sorting

    # for text search:
    text :id
    text :title
    text :description
    text :capacity
    text :sector_comment
    text :year
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
          "#{s.date ? s.date.strftime('%d %B %Y') : ''}",
          "#{s.url.split(/\.|\/|\+|\%20|_/)}"]
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
 
    # All the facets are defined in initializers/search_constants
    (FACETS + WORKFLOW_FACETS).each do |facet|
      string facet[:sym], multiple: (facet[:multiple] || false ) do 
        facet[:code] || self.send(facet[:sym]) 
      end
    end

  end

	
	def scope
	  scope_array = []
    # RDM 2-26-2013 -- Updated for Scope model instead of SCOPES constant
	  Scope.all.each do |scope|
      # Scope_hash is implemented in Scope#includes_project?
      if scope.includes_project? self
        scope_array << scope.symbol.to_sym
      end
    end
	   
    return scope_array
  end

  def scope_names
    scope_array = []
    Scope.all.each do |scope|
      # Scope_hash is implemented in Scope#includes_project?
      if scope.includes_project? self
        scope_array << scope.name
      end
    end
    scope_array
  end
  #test_scope should be a symbol. Check the SCOPE constant for possibilites
  def contains_scope?(test_scope)
    scope_array = scope
    if scope_array.include?(test_scope)
      true
    else
      false
    end
  end


 

   def as_json(options={})
    super(
      only: [:id,:year, :title, :active, :is_commercial, :year_uncertain, :line_of_credit, :is_cofinanced, :debt_uncertain], 
      methods: [:usd_2009, :donor_name,
        :crs_sector_name, :flow_type_name, :oda_like_name, :status_name, 
        # :tied_name, 
        :recipient_condensed
    ],
      include: [
        {geopoliticals: {include: [{recipient: {only: [:name, :iso2, :iso3, :cow_code, :oecd_code]}}], only: [:percent]}},
        {transactions: {include: [{currency: {only: [:name, :iso3]}}], only: [:value, :usd_defl, :usd_current, :deflated_at, :deflator, :exchange_rate]}},
        {contacts: {only: [:name, :position], include: [organization: {only: [:name, :organization_type]}]}},
        {sources: {only: [:url, :date], include: [{source_type: {only: [:name]}}, {document_type: {only:[:name]}}]}},
        {participating_organizations: {only: [], include: [{origin: {only: [:name]}}, {organization: {only: [:name, :organization_type]}}, {role: {only: [:name]}}]}}
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


  def update_geocodes
    #
    # Needs validation
    #
    # require 'open-uri'
    # this_projects_geocodes_url= URI.encode("https://services1.arcgis.com/" +
    # "4AWkjqgSzd8pqxQA/arcgis/rest/services/all_cdf_africa_geo/FeatureServer/" +
    # "query?f=json&layerDefs={'0':'Project_ID=#{id}'}")
    # p response = JSON.parse(open(this_projects_geocodes_url){|io| io.read})


    # codes = response["layers"][0]["features"]
    # if ! codes.blank?
    #   codes.map{|f|
    #     {
    #       latitude: "#{f["Latitude"]}",
    #       longitude: "#{f["Longitude"]}",
    #       geoname: "#{f["Geoname"]}",
    #       geoname_id: "#{f["Geoname_id"]}",
    #       adm1: "#{f["ADM1"]}",
    #       adm2: "#{f["ADM2"]}",
    #       adm3: "#{f["ADM3"]}",
    #       adm4: "#{f["ADM4"]}",
    #       adm5: "#{f["ADM5"]}",
    #       adm1_id: "#{f["ADM1_ID"]}",
    #       adm2_id: "#{f["ADM2_ID"]}",
    #       adm3_id: "#{f["ADM3_ID"]}",
    #       adm4_id: "#{f["ADM4_ID"]}",
    #       adm5_id: "#{f["ADM5_ID"]}",
    #       precision: "#{f["Precision"]}", 
    #       timestamp: "#{f["Timestamp"]}", 
    #       source: "#{f["Source"]}",
    #       source_url: "#{f["sourceURL"]}", 
    #       fid: "#{f["FID"]}",
    #     }
    #   }
    # end

    "not implemented"
  end
end
