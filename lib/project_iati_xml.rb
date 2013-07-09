module ProjectIatiXml

  def as_xml(options={})
    super(
      only: [:id,:year, :title, :active, :is_commercial, :year_uncertain, :line_of_credit, :is_cofinanced, :debt_uncertain], 
      methods: [:usd_2009, :donor_name, :to_english,
        :crs_sector_name, :flow_type_name, :oda_like_name, :status_name, 
        # :tied_name, 
        :recipient_condensed
    ],
      include: [
        {geopoliticals: {include: [{recipient: {only: [:name, :iso2, :iso3, :cow_code, :oecd_code]}}], only: [:percent]}},
        {transactions: {include: [{currency: {only: [:name, :iso3]}}], only: [:value, :usd_defl, :usd_current, :deflated_at, :deflator, :exchange_rate]}},
        {contacts: {only: [:name, :position], include: [organization: {only: [:name, :organization_type]}]}},
        {sources: {only: [:url, :date], include: [{source_type: {only: [:name]}}, {document_type: {only:[:name]}}]}},
        {participating_organizations: {only: [], include: [{origin: {only: [:name]}}, {organization: {only: [:name, :organization_type]}}, {role: {only: [:name]}}]}}
    ]) 
  end
end
