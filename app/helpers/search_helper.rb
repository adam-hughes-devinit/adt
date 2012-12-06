module SearchHelper
	def custom_search(options = {})
	  options.reverse_merge! paginate: true

	   # @facet_labels = ["Sector", "Flow Type", "Flow Class", "Is Commercial", "Active", "Recipient"]
	    @facets = facets = [
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
	      {sym: :year, name: "Commitment Year"}
	    ].sort! { |a,b| a[:name] <=> b[:name] }
	    @search = Project.search do
	        fulltext params[:search]
	        facets.each do |f|
	          facet f[:sym]
	          with f[:sym], params[f[:sym]] if params[f[:sym]].present?
	        order_by((params[:order_by] ? params[:order_by].to_sym : :title), params[:dir] ? params[:dir].to_sym : :desc )
	    end
	    
	  
	    if options[:paginate]==true
	      paginate :page => params[:page] || 1, :per_page => params[:max] || 50
	    end
	  end
	  @projects = @search.results
	end
end
