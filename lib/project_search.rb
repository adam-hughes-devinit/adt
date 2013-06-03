module ProjectSearch
	extend ActiveSupport::Concern

	# Not delegating bc I need "Unset" if nil
	ACCESSORY_METHODS = [
		{
			accessory: :participating_organizations,
			methods: %i{origin_name organization_type_name role_name organization_name}
		},
		{
			accessory: :sources,
			methods:  %i{document_type_name source_type_name}
		},
		{
			accessory: :transactions,
			methods: %i{currency_name }
		},
		{
			accessory: :geopoliticals,
			methods: %i{recipient_name recipient_iso2}
		}
	]
	ACCESSORY_METHODS.each do |a_m|

		accessory = a_m[:accessory]
		
		a_m[:methods].each do |method_name|
		
			define_method "#{method_name}" do
				send(accessory).map{|a| a.send(method_name) || 'Unset'}
		
			end
		end
	end

	included do
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



		def search_engine_type_name
			# alias for search interface & URLs
			source_type_name
		end
		def country_name
			recipient_name.sort
		end
		def recipient_condensed
			recipient_name.count > 1 ? "Africa, regional" : country_name[0]
		end
		def number_of_recipients
			recipient_name.length
		end

		def usd_2009
			# This should be a reduce method
			sum = 0
			transactions.map { |t| sum += (t.usd_defl || 0)} 
			sum > 0 ? sum : nil
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
					"#{g.recipient_name }",
					"#{g.recipient_iso3 }"]
				end
			  end
			end

			text :participating_organizations do
			  participating_organizations.map do |o| 
				["#{o.organization_name }",
				  "#{o.role_name }",
				  "#{o.organization_type_name}"] 
			  end
			end

			text :sources do
			  sources.map do |s| 
				["#{s.url}",
				  "#{s.source_type_name}",
				  "#{s.document_type_name}",
				  "#{s.date ? s.date.strftime('%d %B %Y') : ''}",
				  "#{s.url.split(/\.|\/|\+|\%20|_/)}"]
			  end
			end

			text :transactions do
			  transactions.map do |t| 
				["#{t.currency_name}",
				  "#{t.value}"]
			  end
			end

			text :contacts do
			  contacts.map do |c| 
				["#{c.name}",
				  "#{c.position}",
				  "#{c.organization_name}"]
			  end
			end

			# All the facets are defined in initializers/search_constants
			(FACETS + WORKFLOW_FACETS).each do |facet|
				string facet[:sym], multiple: (facet[:multiple] || false ) do 
					facet[:code] || self.send(facet[:sym]) 
				end
			end

		end
	end
end
