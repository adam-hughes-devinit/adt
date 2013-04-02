
  
  FACETS = [
      {sym: :flow_type_name, name: "Flow Type"},
      {sym: :oda_like_name, name: "Flow Class"},
      {sym: :status_name, name:"Status"},
      {sym: :verified_name, name:"Verified/Unverified"},
      {sym: :currency_name, name:"Reported Currency", multiple: true},
      {sym: :is_commercial_string, name: "Commercial Status"},
      {sym: :active_string, name: "Active/Inactive"},
      {sym: :country_name, name: "Recipient", multiple: true},
      {sym: :source_type_name, name: "Source Type", multiple: true},
      {sym: :document_type_name, name: "Document Type", multiple: true},
      {sym: :origin_name, name: "Organization Origin", multiple: true},
      {sym: :role_name, name: "Organization Role", multiple: true},
      {sym: :organization_type_name, name: "Organization Type", multiple: true},
      {sym: :organization_name, name: "Organization Name", multiple: true},
      {sym: :owner_name, name: ""},
      {sym: :line_of_credit_string, name: "Line of Credit"},
      {sym: :crs_sector_name, name: "CRS Sector"},
      {sym: :year_uncertain_string, name: "Year Uncertain"},
      {sym: :debt_uncertain_string, name: "Debt Relief Uncertain"},
      {sym: :is_cofinanced_string, name: "Cofinance Status"},
      {sym: :recipient_iso2, name: "", multiple: true},
      {sym: :number_of_recipients, name: "Number of Recipients"},
      {sym: :year, name: "Commitment Year"},
      {sym: :intent_name, name: "Intent"},
      {sym: :loan_type_name, name: "Loan Type"},
      {sym: :interest_rate_band, name: "Interest Rate"},
      {sym: :maturity_band, name: "Maturity"},
      {sym: :grace_period_band, name: "Grace Period"},
      {sym: :grant_element_band, name: "Grant Element"},
      {sym: :scope_names, name: "Scope", multiple: true}
    ].sort! { |a,b| a[:name] <=> b[:name] }
    
    
    WORKFLOW_FACETS = [
    	{sym: :flow_class_arbitrated, name: "Flow Class - Arbitrated"},
    	{sym: :flow_class_1, name: "Flow Class - 1"},
    	{sym: :flow_class_2, name: "Flow Class - 2"},
    	{sym: :flagged, name: "Flagged", multiple: true },
    	# {sym: :commented, name: "Commented"},
    ]

