class Transaction < ActiveRecord::Base
	include VersionsHelper
  attr_accessible :currency_id, :usd_defl, :value, :project_id, :currency, 
  :usd_current, :deflator_used, :exchange_rate, 
  :deflated_at, :deflator, :created_at, :updated_at

  attr_accessor :rate_error, :defl_error

  before_save :deflate_and_round_value
  include ProjectAccessory

  belongs_to :currency
  delegate :name, :iso3, to: :currency, allow_nil: true, prefix: true
  
  def to_iati
    
    iati_values = []
    if usd_defl.present? && (currency_iso3!="USD") && (project.year != 2009 )
      iati_values << %{
        <value currency="USD" value-date="2009-01-01">
          #{usd_defl}
        </value>
      }
    end
    if usd_current.present? && (currency_iso3!="USD")
      iati_values << %{
        <value currency="USD" value-date="#{date_iso8601}">
          #{usd_current}
        </value>
      }
    end

    %{
      <transaction ref="#{id}">
        <transaction-date iso-date="#{date_iso8601}" />
        <transaction-type code="C" />
        <value currency="#{currency_iso3}" value-date="#{date_iso8601}">
          #{value}
        </value>
        #{ iati_values.join }
      </transaction>
    }
  end

  def date_iso8601
    raw_date = project.start_planned || project.start_actual || project.year.present? ? "01-01-#{project.year}".to_date : (project.end_actual || project.end_planned )
    raw_date ? raw_date.iso8601 : nil
  end

  def get_exchange_rate(from_currency_iso3, to_currency_iso3, year)
    exchange = ExchangeRate.joins(:from_currency, :to_currency).where(year: year, currencies: {iso3: from_currency_iso3}, to_currencies_exchange_rates: {iso3: to_currency_iso3 })
    return exchange
  end

  def get_gdp_deflator(donor_iso3, year)
    gdp_defl = Deflator.joins(:country).where(year: year, countries: {iso3: donor_iso3 })
    return gdp_defl
  end

  def set_all_transaction_attributes_to_nil
    self.usd_defl=nil
    self.usd_current=nil
    self.deflator=nil
    self.exchange_rate=nil
    self.deflated_at=nil
  end

	def deflate_and_round_value
      if self.project && self.project.year && self.project.donor
        donor_iso3 = self.project.donor.iso3
        yr = self.project.year
          if self.value && self.currency

            # This joins assumes the "to_currency" is US Dollars.
            begin
              exchange_rate_used = get_exchange_rate(self.currency.iso3, 'USD', yr)[0].rate
            rescue  # this error messages are currently not being displayed anywhere.
              exchange_rate_used = nil
              self.rate_error = "Exchange rate for ? ? could not be found", yr, self.currency.iso3
            end

            begin
              defl = get_gdp_deflator(donor_iso3, yr)[0].value
            rescue   # this error messages are currently not being displayed anywhere.
              defl = nil
              self.defl_error = "GDP deflator for ? ? could not be found", yr, donor_iso3
            end

            if exchange_rate_used != nil && defl != nil

              usdCurrent = (self.value / exchange_rate_used)
              deflator_used = (defl / 100)
              deflated_amount = (usdCurrent / deflator_used)

              self.usd_defl= deflated_amount
              self.usd_current= usdCurrent
              self.deflator= deflator_used
              self.exchange_rate = exchange_rate_used
              self.deflated_at = Time.now

            else
              set_all_transaction_attributes_to_nil
            end

          else
            set_all_transaction_attributes_to_nil
          end
      end
   end
end
