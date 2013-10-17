class Transaction < ActiveRecord::Base
	include VersionsHelper
  attr_accessible :currency_id, :usd_defl, :value, :project_id, :currency, 
  :usd_current, :deflator_used, :exchange_rate, 
  :deflated_at, :deflator, :created_at, :updated_at
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


	def deflate_and_round_value
      puts "deflating stuff!!!!!!!!!!!!!!"
      if self.project && self.project.year && self.project.donor
        donor_iso3 = self.project.donor.iso3
        yr = self.project.year
          if self.value && self.currency 
            require 'open-uri'

            deflator_query = "#{self.value.to_s}#{self.currency.iso3}#{yr}#{donor_iso3}" # This is defined at oscar.itpir.wm.edu/deflate
            deflator_url = "https://oscar.itpir.wm.edu/deflate/api.php?val=#{deflator_query}&json=true"
            # p "Deflating #{deflator_url}"
            deflator_string = open(deflator_url){|io| io.read}
            
            deflator_object = ActiveSupport::JSON.decode(deflator_string)
           
            begin  
              
              deflated_amount = deflator_object["deflated_amount"]
              current_amount =  deflator_object["current_amount"]
              exchange_rate_used = deflator_object["exchange_rate"]
              deflator_used = deflator_object["deflator"]
              #p "Deflated is #{deflated_amount.class}, Currency is #{current_amount.class}"

              self.usd_defl= deflated_amount
              self.usd_current = current_amount
              self.deflator= deflator_used
              self.exchange_rate = exchange_rate_used
              self.deflated_at = Time.now


            rescue
                
                self.usd_defl=nil
                self.usd_current=nil
                self.deflator=nil
                self.exchange_rate=nil
                self.deflated_at=nil

            end

          else
                self.usd_defl=nil
                self.usd_current=nil
                self.deflator=nil
                self.exchange_rate=nil
                self.deflated_at=nil
          end
      end
   end

end
