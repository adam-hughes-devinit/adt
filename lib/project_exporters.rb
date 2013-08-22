module ProjectExporters

  # AKA Project#csv_text
    
  def csv_text
    
    # Maintain the Project#csv_text API as to not break code.

     Rails.cache.fetch("project_csv_text/#{self.id}") do
          self.create_csv_text
     end
     
  end

  def expire_csv_text
    Rails.cache.delete("project_csv_text/#{self.id}")
  end

  def create_csv_text
    

    project_sources = {
        all: [],
        factiva: []
    }
    resources.each do |r|
        as_text = "#{r.source_url}, #{r.resource_type || "(type unknown)"}"
        project_sources[:all] << as_text
        project_sources[:factiva] << as_text if r.source_url.downcase =~ /factiva/
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
    location_details = ""
    geopoliticals.each_with_index do |g, i| 
        g.recipient ? cached_recipients.push(g.recipient) : nil 
        location_details << (g.subnational ? "#{location_details.present? ? ", " : ""}#{g.subnational}" : "")
    end

    export_contacts = contacts.map(&:to_english).join("; ") 
    
    csv_array = %W[
    #{id}
    #{donor_name}
    #{title}
    #{year}
    #{year_uncertain}
    #{description}
    #{crs_sector_code}
    #{crs_sector_name}
    #{sector_comment}
    #{status_name}
    #{status ? status.code : ''}
    #{flow_type_name}
    #{country_name.join(", ")}
    #{project_sources[:all].join("; ")}
    #{project_sources[:all].count}
    #{project_agencies[:Funding].join('; ')}
    #{project_agencies[:Implementing].join("; ")}
    #{project_agencies[:Donor].join("; ")}
    #{project_agencies[:Donor].any? ? project_agencies[:Donor].count : ''}
    #{project_agencies[:Recipient].join('; ')}
    #{project_agencies[:Recipient].any? ? project_agencies[:Recipient].count : ''}
    #{verified_name}
    #{verified ? verified.code : '' }
    #{oda_like_name}
    #{oda_like ? oda_like.code : '' }
    #{intent_name}
    #{intent ? intent.code : '0' }
    #{active_string}
    #{active ? 1 : 2}
    #{project_sources[:factiva].join("; ")}
    #{transactions.map{|t| t.value}.join("; ")}
    #{transactions.map{|t| t.currency ? t.currency.iso3 : '' }.join("; ")}
    #{transactions.map{|t| t.deflator}.join("; ")}
    #{transactions.map{|t| t.exchange_rate}.join("; ")}
    #{usd_2009}
    #{usd_2009_current}
    #{start_actual ? start_actual.strftime("%d %B %Y") : ''}
    #{start_planned ?  start_planned.strftime("%d %B %Y") : ''}
    #{end_actual ? end_actual.strftime("%d %B %Y") : ''}
    #{end_planned ? end_planned.strftime("%d %B %Y"): '' }
    #{country_name.any? ? country_name.count : ''}
    #{recipient_condensed}
    #{cached_recipients.map(&:cow_code).join("; ")}
    #{cached_recipients.map(&:oecd_code).join("; ")}
    #{cached_recipients.map(&:oecd_name).join("; ")}
    #{cached_recipients.map(&:iso3).join("; ")}
    #{cached_recipients.map(&:iso2).join("; ")}
    #{cached_recipients.map(&:un_code).join("; ")}
    #{cached_recipients.map(&:imf_code).join("; ")}
    #{debt_uncertain}
    #{line_of_credit}
    #{is_cofinanced}
    #{loan_type_name}
    #{interest_rate}
    #{maturity}
    #{grace_period}
    #{grant_element}
    #{updated_at}
    #{location_details}
    #{export_contacts}]



    #TODO fix loan_type line above ^ this is a hack because loan_type is designed wrong
    csv_text_string = ""
    # I think it brought the line breaks etc. into the strings -->
    csv_array.each do |v| 
        csv_text_string << "\"#{v.gsub(/"/, "'").gsub(/[\n\r\t\s]+/, ' ')}\"," 
    end


    csv_text_string << "#{ self.scope.include?(:official_finance) ? 1 : 0 }"

    # get rid of that trailing comma
    csv_text_string.chomp!(',')

    return csv_text_string
  end
end
