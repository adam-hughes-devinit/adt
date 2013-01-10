module AggregatesHelper	

	VALUE_DELIMITER = "*" 
	
	VALID_FIELDS = [
			{external: "donor", name: "Donor", internal: "donors.iso3", group: "donors.iso3", sorter: "donors.iso3 asc" },
			{external: "status", name: "Status", group: "statuses.name", internal: "(case when statuses.name is null then 'Unset' else statuses.name end)", sorter: "status asc"},
			{external: "sector_name", name: "Sector", internal: "(case when sectors.name is null then 'Unset' else sectors.name end)", group: "sectors.name", sorter: "sector_name asc"},
			{external: "flow_class", name: "Flow Class", group: "oda_likes.name", internal: "(case when oda_likes.name is null then 'Unset' else oda_likes.name end) ", sorter: "flow_class asc"},
			{external: "recipient_iso2",  name: "Recipient ISO2", group: "recipient_iso2", internal: "recipient_iso2", sorter: "recipient_iso2 asc"},
			{external: "recipient_iso3",   name: "Recipient ISO3", group: "recipient_iso3", internal: "recipient_iso3", sorter: "recipient_iso3 asc"},			
			{external: "recipient_name", name: "Recipient Name",   group: "recipient_name", internal: "recipient_name", sorter: "recipient_name asc"},
			{external: "year",  name: "Year", internal: "year", group: "year", sorter: "year desc"}
			# active 
		]
		
	
	WHERE_FILTERS = [
	    	{sym: :recipient_iso2, name: "Recipient ISO2", options: Country.all.map{|c| c.iso2} , internal_filter: "recipient_iso2"},
	    	{sym: :recipient_name, name: "Recipient Name", options: Country.all.map{|c| c.name} , internal_filter: "recipient_name"},
	    	{sym: :sector_name, name: "Sector Name", options:Sector.all.map{|c| c.name} , internal_filter: "sectors.name"},
	    	{sym: :verified, name: "Verified Status", options: Verified.all.map{|c| c.name} , internal_filter: "verifieds.name"},
	    	{sym: :flow_type, name: "Flow Type", options: FlowType.all.map{|c| c.name} , internal_filter: "flow_types.name"},
	    	{sym: :flow_class, name: "Flow Class", options: OdaLike.all.map{|o| o.name}, internal_filter: "oda_likes.name" },
	    	{sym: :status, name: "Status", options: Status.all.map{|o| o.name}, internal_filter: "statuses.name" },
	    	{sym: :year, name: "Year", options: ("2000".."2010").to_a.reverse! , internal_filter: "year" }
	    ]
	
		
		DUPLICATION_HANDLERS = [
				# MERGE --> If a project has multiple recipients, call it "Africa, Regional"
				{external: "merge", name: "Merge",
				 note: "If a project has multiple recipients, call it 'Africa, Regional'",
						select: '@recipient_field_names.map{ |fn| "(case when count(recipients.id) > 1 then #{ africa_regional_iso2(fn)} " +
									"else max(recipients.#{fn}) end) as recipient_#{fn}" }.join(", ")', 
						group: "group by projects.id", 
						join: "INNER JOIN geopoliticals geo on projects.id = geo.project_id "+
									"INNER JOIN countries recipients on geo.recipient_id = recipients.id",
						amounts: "round(cast(sum(sum_usd_defl) as numeric),2) as usd_2009, round(cast(sum(sum_usd_current) as numeric),2) as usd_current"
						}, 
								
				# PERCENT THEN MERGE --> If a project has multiple recipients and percentages add up to 100, 
				#															Then divide along those percentages
				#												 Else call it "Africa, Regional"
				{external: "percent_then_merge", name: "Percent Then Merge",
				 note: 'If a project has multiple recipients and percentages add up to 100, then divide along those percentages, else call it "Africa, Regional"',
						select: '@recipient_field_names.map { |fn| "(case when ((select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) > 1 AND (select sum(percent) from geopoliticals g3 where g3.project_id=geo.project_id group by project_id) != 100) then #{africa_regional_iso2(fn)} else recipients.#{fn} end ) as recipient_#{fn}"}.join(", ") + ", (case when ((select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) > 1 AND (select sum(percent) from geopoliticals g3 where g3.project_id=geo.project_id group by project_id) = 100) then geo.percent/100.0 else 1.0 end) as multiplier"',
						group: "", 
						join: "LEFT OUTER JOIN geopoliticals geo on projects.id = geo.project_id " +
									"INNER JOIN countries recipients on geo.recipient_id=recipients.id",
						amounts: "round(cast(sum(sum_usd_defl*p.multiplier) as numeric), 2) as usd_2009, round(cast(sum(sum_usd_current*p.multiplier) as numeric), 2) as usd_current"
						 },
				 
				# PERCENT THEN SHARE --> If a project has multiple recipients and percentages add up to 100, 
				#															Then divide along those percentages
				#												 Else share it equally among recipients
				{external: "percent_then_share", name: "Percent Then Share",
				 note: "If a project has multiple recipients and percentages add up to 100, then divide along those percentages, else share it equally among recipients",
						select: '@recipient_field_names.map { |fn| "recipients.#{fn} as recipient_#{fn}"}.join(", ") + 
									", (case when ((select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) > 1 AND (select sum(percent) from geopoliticals g3 where g3.project_id=geo.project_id group by project_id) = 100) then geo.percent/100.0 else (select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id)/1.0 end) as multiplier"',
						group: "",
						join:"LEFT OUTER JOIN geopoliticals geo on projects.id = geo.project_id " +
									"INNER JOIN countries recipients on geo.recipient_id=recipients.id",
						amounts: "round(cast(sum(sum_usd_defl*p.multiplier) as numeric), 2) as usd_2009, round(cast(sum(sum_usd_current*p.multiplier) as numeric),2) as usd_current"
						 },
				
				# SHARE --> If a project has multiple recipients, share the amount equally among recipients
				{external: "share", name: "Share",
				 note: "If a project has multiple recipients, share the amount equally among recipients",
						select: '@recipient_field_names.map { |fn| "recipients.#{fn} as recipient_#{fn}"}.join(", ") + ",(select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) as recipients_count"' ,
						group: "", 
						join: "LEFT OUTER JOIN geopoliticals geo on projects.id = geo.project_id " +
									"INNER JOIN countries recipients on geo.recipient_id=recipients.id",
						amounts: "round(cast(sum(sum_usd_defl/p.recipients_count) as numeric),2) as usd_2009, round(cast(sum(sum_usd_current/p.recipients_count) as numeric),2) as usd_current"
						},
						
				# DUPLICATE --> If a project has multiple recipients, allocate the full amount to each recipient (DOUBLE-COUNTING)
				{external: "duplicate", name: "Duplicate",
					note: "If a project has multiple recipients, allocate the full amount to each recipient (DOUBLE-COUNTING)",
						select: '@recipient_field_names.map { |fn| "recipients.#{fn} as recipient_#{fn}"}.join(", ") ',
						group: "",
						join: "LEFT OUTER JOIN geopoliticals geo on projects.id = geo.project_id " +
									"INNER JOIN countries recipients on geo.recipient_id=recipients.id",
						amounts: "round(cast(sum(sum_usd_defl) as numeric), 2) as usd_2009, round(cast(sum(sum_usd_current) as numeric),2) as usd_current"
						}
			]
end
