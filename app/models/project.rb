class Project < ActiveRecord::Base
  include ProjectCache
  include ProjectExporters
  extend  ProjectExporterHeaders

  attr_accessible :title, :active, :capacity, :description, :year,
    :start_actual, :start_planned, :end_actual, :end_planned, :sector_comment,
    :is_commercial, :media_id, 
    :year_uncertain, :debt_uncertain, :line_of_credit, :crs_sector, 
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
    :donor_id, :owner_id, :intent_id

  before_save :set_verified_to_raw_if_null
  # before_save :deflate_values MOVED TO TRANSACTION MODEL
  after_save :cache!
  after_destroy :remake_scope_files

  def remake_scope_files
    scope.each do |s|
      cache_files(s)
    end
  end 

  # before_save :increment_iteration MOVED TO FORM

  def increment_iteration # DUH, version was already taken by paper_trail
    iteration ||= 0
    iteration += 1
  end


  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :exports
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

  has_one :loan_detail, dependent: :destroy
  accepts_nested_attributes_for :loan_detail

  def loan_type
    if loan_detail.nil?
      "Unset"
    else
      loan_detail.loan_type
    end
  end

  def interest_rate
    if loan_detail.nil?
      "Unset"
    else
      loan_detail.interest_rate
    end
  end

  def maturity
    if loan_detail.nil?
      "Unset"
    else
      loan_detail.maturity
    end
  end

  def grace_period
    if loan_detail.nil?
      "Unset"
    else
      loan_detail.grace_period
    end
  end

  def grant_element
    if loan_detail.nil?
      "Unset"
    else
      loan_detail.grant_element
    end
  end

  #
  #  End restructuring
  #

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

  searchable do 
    integer :id # only for searching
    text :id

    float :usd_2009

    text :title
    string :title

    text :description
    text :capacity
    text :sector_comment

    text :year
    string :year

    text :donor_name
    string :donor_name

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

    string :number_of_recipients
    string :owner_name
    string :sector_name 
    string :flow_type_name
    string :oda_like_name
    string :flow_class_arbitrated # These three are for workflow
    string :flow_class_1
    string :flow_class_2
    string :intent_name
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
    string :loan_type
    string :interest_rate
    string :maturity
    string :grace_period
    string :grant_element

    string :scope, multiple: true

    string :flagged, multiple: true do 
      all_flags.map(&:name)
    end


    string :recipient_iso2, multiple: true do
      geopoliticals.map { |g| g.recipient ? g.recipient.iso2 : "Unset" }
    end

  end

	
	def scope
	  scope_array = []
    # RDM 2-26-2013 -- Updated for Scope model instead of SCOPES constant
    
    #check the Scope architecture in the search constant initializer
	  Scope.all.each do |scope|
      if scope.includes_project? self
        scope_array << scope.symbol.to_sym
      end
    end
	   
    return scope_array
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
