module ProjectExporterHeaders

  def csv_header
    csv_header_array = %W[project_id donor title year year_uncertain
    description sector sector_comment crs_sector status status_code flow
    all_recipients sources sources_count funding_agency implementing_agency
    donor_agency donor_agency_count recipient_agencies recipient_agencies_count
    verified verified_code flow_class flow_class_code intent intent_code
    active active_code factiva_sources amount currency deflators_used
    exchange_rates_used usd_defl start_actual start_planned end_actual
    end_planned recipient_count recipient_condensed recipient_cow_code
    recipient_oecd_code recipient_oecd_name recipient_iso3 recipient_iso2
    recipient_un_code recipient_imf_code is_commercial is_commercital 
    debt_uncertian line_of_credit is_cofinanced loan_type interest_rate 
    maturity grace_period
    grant_element]

    csv_header_string = ""
    csv_header_array.each {|v| csv_header_string << "\"#{v}\"," }
    #Get rid of trailing comma
    csv_header_string.chomp!(',')

    return csv_header_string
  end

end
