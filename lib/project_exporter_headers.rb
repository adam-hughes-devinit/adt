module ProjectExporterHeaders

  def csv_header
    csv_header_array = %W[project_id donor title year year_uncertain
    description crs_sector_code crs_sector_name sector_comment status status_code flow
    all_recipients sources sources_count funding_agency implementing_agency
    donor_agency donor_agency_count recipient_agencies recipient_agencies_count
    verified verified_code flow_class flow_class_code intent intent_code
    active active_code factiva_sources amount currency deflators_used
    exchange_rates_used usd_defl usd_current start_actual start_planned end_actual
    end_planned recipient_count recipient_condensed recipient_cow_code
    recipient_oecd_code recipient_oecd_name recipient_iso3 recipient_iso2
    recipient_un_code recipient_imf_code 
    debt_uncertian line_of_credit is_cofinanced loan_type interest_rate 
    maturity grace_period
    grant_element updated_at location_details contacts]

    
    csv_header_string = ""
    csv_header_array.each {|v| csv_header_string << "\"#{v}\"," }

    # Brian says he only wants is_official
    # Scope.all.each do |scope|
    #     csv_header_string << "is_#{scope.symbol},"
    # end

    csv_header_string << "is_official_finance"

    #Get rid of trailing comma
    csv_header_string.chomp!(',')

    return csv_header_string
  end

end
