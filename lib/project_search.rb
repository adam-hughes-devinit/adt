module ProjectSearch
  extend ActiveSupport::Concern

  # Note: New facets may not immediately appear in the search filter.
  # You need to save some projects to update the cache.
  FACETS = [
    {sym: :flow_type_name, name: "Flow Type"},
    {sym: :oda_like_name, name: "Flow Class"},
    {sym: :status_name, name:"Status", description: "Last known implementation status"},
    {sym: :currency_name, name:"Reported Currency", multiple: true, description: "Currency found in source data"},
    {sym: :is_commercial_string, name: "", description: "Is the project commercial?"}, #"Commercial Status"
    {sym: :active_string, name: "Active/Inactive", description: "Inactive records should not be used for analysis."},
    {sym: :country_name, name: "Recipient", multiple: true},
    {sym: :source_type_name, name: "", multiple: true},
    {sym: :search_engine_type_name, name: "Search Engine Type", multiple: true, description: "How did we find this source?"},
    {sym: :document_type_name, name: "Document Type", multiple: true},
    {sym: :origin_name, name: "Organization Origin", multiple: true},
    {sym: :role_name, name: "Organization Role", multiple: true},
    {sym: :organization_type_name, name: "Organization Type", multiple: true},
    {sym: :organization_name, name: "Organization Name", multiple: true},
    {sym: :line_of_credit_string, name: "Line of Credit", description: "Is the project a line of credit?"},
    {sym: :crs_sector_name, name: "Sector", description: "Sector, using CRS high-level codes."},
    {sym: :year_uncertain_string, name: "Year Uncertain", description: "Year could not be determined"},
    {sym: :debt_uncertain_string, name: "Debt Relief Uncertain", description: "Unclear whether this is debt relief"},
    {sym: :is_cofinanced_string, name: "", description: "Was this project cofinanced?"}, #"Cofinance Status"
    {sym: :is_ground_truthing_string, name: "", description: "Was this project ground truthing?"},
    {sym: :recipient_iso2, name: "", multiple: true},
    {sym: :number_of_recipients, name: "Number of Recipients"},
    {sym: :year, name: "Commitment Year", description: "Data from 2012 and 2013 is not yet comprehensive"},
    {sym: :intent_name, name: "Intent"},
    {sym: :loan_type_name, name: "Loan Type"},
    {sym: :interest_rate_band, name: "Interest Rate"},
    {sym: :maturity_band, name: "Maturity"},
    {sym: :grace_period_band, name: "Grace Period"},
    {sym: :grant_element_band, name: "Grant Element"},
    {sym: :scope_names, name: "Scope", multiple: true, description: ""}
  ].sort! { |a,b| a[:name] <=> b[:name] }

  WORKFLOW_FACETS = [
    {sym: :donor_name, name: "Donor"},
    {sym: :flow_class_arbitrated, name: "Flow Class - Arbitrated"},
    {sym: :flow_class_1, name: "Flow Class - 1"},
    {sym: :flow_class_2, name: "Flow Class - 2"},
    {sym: :flagged, name: "Flagged", multiple: true },
    {sym: :commented, name: "Commented"},
    {sym: :verified_name, name: "Verified", description: "Is the record valid? (\"Raw\" is invisible to non-AidData)"}, #"Verified/Unverified"
    {sym: :is_stage_one, name: "Is Stage One?", description: '"Raw" & "Active"'},
    {sym: :owner_name, name: "Record Owner", description: "Who created this record?"},
    # {sym: :commented, name: "Commented"},
  ]

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

    def is_ground_truthing_string
      is_ground_truthing ? "Ground Truthing" : "Not Ground Truthing"
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

    def usd_2009_current
      # This should be a reduce method
      sum = 0
      transactions.map { |t| sum += (t.usd_current || 0)}
      sum > 0 ? sum : nil
    end

    searchable do 
      # for sorting
      integer :id 
      double :usd_2009 
      string :title 
      string :donor_name 
      string :recipient_condensed 
      date :updated_at

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

      (FACETS + WORKFLOW_FACETS).each do |facet|
        string facet[:sym], multiple: (facet[:multiple] || false ) do 
          facet[:code] || self.send(facet[:sym]) 
        end
      end

    end

    # Nice idea, but I need it to show up in the search bar ~pronto~
    # handle_asynchronously :solr_index if Rails.env.production?
    def self.facet_counts
      Rails.cache.fetch("projects/faceted") do
        # wipe it in ProjectSweeper!
        facets = (WORKFLOW_FACETS + FACETS)
        all_projects = Project.solr_search do
          facets.each do |f|
            facet f[:sym]
          end
        end
        facet_counts = {}
        facets.each do |f|
          if this_facet = all_projects.facet(f[:sym])
            facet_values = this_facet.rows.sort!{|a,b| a.value <=> b.value}.map(&:value)
          facet_counts[f[:sym]] = facet_values
          end
        end
        facet_counts
      end
    end

  end
end
