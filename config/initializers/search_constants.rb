		SCOPES = [
	# Official Finance: 
  #		- Active
  #   - Checked
  #		- ODA-like, OOF-like, Vague (ODF)
  #		- NOT Cancelled or Suspended
						{sym: :official_finance, 
						 name: "Official Finance (CDF)",
						 with_and: {oda_like_name: ["OOF-like", "ODA-like", "Vague (ODF)"],
												 active_string: "Active",
												 verified_name: "Checked"},
						 without: {status_name: ["Cancelled", "Suspended"]},
						 #with_or: {none: nil}
						},
	# Unofficial Finance
	#		- Active
	#		- CA, JV, FDI, NGO, Vague (COM)
	#   - Checked
						{sym: :unofficial_finance, 
						 name: "Unofficial Flows",
						 with_and: {oda_like_name: ["JV +Gov", "JV -Gov","CA +SOE", "CA -SOE", "FDI +Gov", "FDI -Gov", "NGO Aid", "Vague (Com)"],
												 active_string: "Active",
												 verified_name: "Checked"},
						 without: {none: nil}
						 #with_or: {none: nil}
						},
	# Military
	#		 - Military
	#		 - Active
	#		 - Checked
						{sym: :military, 
						 name: "Military Flows", 
						 with_and: {oda_like_name: ["Military"],
												 active_string: "Active",
												 verified_name: "Checked"},
						 without: {none: nil}
						 #with_or: {none: nil}
						},
	
	# Cancelled
	#		 - Cancelled
	#		 - Active
	#		 - Checked	
						{sym: :cancelled, 
						 name: "Cancelled Activities", 
						 with_and: {status_name: "Cancelled",
												 active_string: "Active",
												 verified_name: "Checked"},
						 without: {none: nil}
						 #with_or: {none: nil}
						},
	# Inactive and Suspicious
	#		 - Suspicious OR Inactive
						{sym: :suspicious_or_inactive, 
						 name: "Suspicious or Inactive Records",
						 with_and: {none: nil},
						 without: {none: nil},
						 with_or: {active_string: "Inactive",
  									 verified_name: "Suspicious"}
						}]
  
  FACETS = [
      {sym: :sector_name, name: "Sector"},
      {sym: :flow_type_name, name: "Flow Type"},
      {sym: :oda_like_name, name: "Flow Class"},
      {sym: :status_name, name:"Status"},
      # {sym: :tied_name, name:"Tied/Untied"}, # saved here just in case!
      {sym: :verified_name, name:"Verified/Unverified"},
      {sym: :currency_name, name:"Reported Currency"},
      {sym: :is_commercial_string, name: "Commericial Status"},
      {sym: :active_string, name: "Active/Inactive"},
      {sym: :country_name, name: "Recipient"},
      {sym: :source_type_name, name: "Source Type"},
      {sym: :document_type_name, name: "Document Type"},
      {sym: :origin_name, name: "Organization Origin"},
      {sym: :role_name, name: "Organization Role"},
      {sym: :organization_type_name, name: "Organization Type"},
      {sym: :organization_name, name: "Organization Name"},
      {sym: :owner_name, name: "Record Owner"},
      {sym: :line_of_credit_string, name: "Line of Credit"},
      {sym: :crs_sector, name: "CRS Sector"},
      {sym: :year_uncertain_string, name: "Year Uncertain"},
      {sym: :debt_uncertain_string, name: "Debt Relief Uncertain"},
      {sym: :is_cofinanced_string, name: "Cofinance Status"},
      {sym: :recipient_iso2, name: ""},
      {sym: :number_of_recipients, name: "Number of Recipients"},
      {sym: :year, name: "Commitment Year"},
      {sym: :intent_name, name: "Intent"}
    ].sort! { |a,b| a[:name] <=> b[:name] }
    
    
    WORKFLOW_FACETS = [
    	{sym: :flow_class_arbitrated, name: "Flow Class - Arbitrated"},
    	{sym: :flow_class_1, name: "Flow Class - 1"},
    	{sym: :flow_class_2, name: "Flow Class - 2"}
    ]
