module ProjectIatiXml

  extend ActiveSupport::Concern

  
  included do
    # call Project.wrap_in_iati( Project.search(...) )
    def self.wrap_in_iati(search_result)

      projects = search_result

      iati_activities = %{
        <iati-activities 
          version="1.02" 
          generated-datetime="#{DateTime.now.iso8601}"
          page="#{ search_result.last_page? ? search_result.total_pages :  1 + (search_result.offset / search_result.count)}"
          pages="#{search_result.total_pages}"
          per_page="#{search_result.count}"
        >
        #{ projects.map(&:to_iati).join }
        </iati-activities>
      }

      iati_activities
    end
  end

  def to_iati
    Rails.cache.fetch("/projects/#{id}/xml") do
      to_xml
    end
  end

  def expire_xml
    Rails.cache.delete("/projects/#{id}/xml")
  end



  def to_xml(options={})
    # super(
    #   only: [:id,:year, :title, :active, :is_commercial, :year_uncertain, :line_of_credit, :is_cofinanced, :debt_uncertain], 
    #   methods: [:usd_2009, :donor_name, :to_english,
    #     :crs_sector_name, :flow_type_name, :oda_like_name, :status_name, 
    #     # :tied_name, 
    #     :recipient_condensed
    # ],
    #   include: [
    #     {geopoliticals: {include: [{recipient: {only: [:name, :iso2, :iso3, :cow_code, :oecd_code]}}], only: [:percent]}},
    #     {transactions: {include: [{currency: {only: [:name, :iso3]}}], only: [:value, :usd_defl, :usd_current, :deflated_at, :deflator, :exchange_rate]}},
    #     {contacts: {only: [:name, :position], include: [organization: {only: [:name, :organization_type]}]}},
    #     {sources: {only: [:url, :date], include: [{source_type: {only: [:name]}}, {document_type: {only:[:name]}}]}},
    #     {participating_organizations: {only: [], include: [{origin: {only: [:name]}}, {organization: {only: [:name, :organization_type]}}, {role: {only: [:name]}}]}}
    # ]) 
    
    iati_dates = []
    %w{start-planned start-actual end-planned end-actual}.each do |date_type|
        if (date_value = self.send(date_type.sub(/-/, "_")))
            iati_dates << "<activity-date type=\"#{date_type}\" iso-date=\"#{date_value.iso8601}\"/>"
        end
    end

    iati_contacts = contacts.map(&:to_iati)
    iati_participating_orgs = participating_organizations.map(&:to_iati)
    iati_recipients = geopoliticals.map(&:to_iati)
    iati_policy_markers = [] #stubbed :(
    iati_transactions = transactions.map(&:to_iati)
    iati_document_links = resources.map(&:to_iati)

    
    iati_text = %{
    <iati-activity xml:lang="en" default-currency="USD" last-updated-datetime="#{updated_at}" hierarchy="1">
        <reporting-org type="80">AidData</reporting-org>
        <iati-identifier>AidData-China-#{id}</iati-identifier>
        <other-identifier owner-name="AidData China">#{id}</other-identifier>
        <activity-website>http://china.aiddata.org/projects/#{id}</activity-website>
        <title>#{title}</title>
        <description type="1">#{description}</description>
        <activity-status #{status_code.present? ? "code=\"#{status_code}\"" : "" }>#{status_name}</activity-status>
        #{ iati_dates.join }
        #{ iati_contacts.join }
        #{ iati_participating_orgs.join }
        #{ iati_recipients.join }
        <sector code="#{crs_sector_code}" vocabulary="DAC-3">#{crs_sector_name}</sector>
        #{iati_policy_markers.join}
        <collaboration-type></collaboration-type>
        <default-finance-type code="#{ flow_type_iati_code }">#{flow_type_name}</default-finance-type>
        <default-flow-type>#{oda_like_name}</default-flow-type>
        #{ iati_transactions.join }
        #{ iati_document_links.join }

    </iati-activity>
    }

    iati_text.gsub(/&/, '&amp;')
  end

end
