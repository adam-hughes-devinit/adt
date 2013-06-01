class Transaction < ActiveRecord::Base
	include VersionsHelper
  attr_accessible :currency_id, :usd_defl, :value, :project_id, :currency, 
  :usd_current, :deflator_used, :exchange_rate, :deflated_at, :deflator, :created_at, :updated_at
  before_save :deflate_and_round_value
  include ProjectAccessory

  belongs_to :currency
  
	def deflate_and_round_value
      if self.project && self.project.year && self.project.donor
        donor_iso3 = self.project.donor.iso3
        yr = self.project.year
          if self.value && self.currency 
            require 'open-uri'

            deflator_query = "#{self.value.to_s}#{self.currency.iso3}#{yr}#{donor_iso3}" # This is defined at oscar.itpir.wm.edu/deflate
            deflator_url = "https://oscar.itpir.wm.edu/deflate/api.php?val=#{deflator_query}&json=true"
            deflator_string = open(deflator_url){|io| io.read}
            # p "JSON Response: #{deflator_string}"
            
            deflator_object = ActiveSupport::JSON.decode(deflator_string)
            # p "Parsed JSON: #{deflator_object.inspect}"
           
            # This is me being lazy because there might be an error
            begin  
              
              deflated_amount = deflator_object["deflated_amount"]
              current_amount =  deflator_object["current_amount"]
              exchange_rate_used = deflator_object["exchange_rate"]
              deflator_used = deflator_object["deflator"]
              #p "Deflated is #{deflated_amount.class}, Currency is #{current_amount.class}"

              self.usd_defl= deflated_amount
              self.usd_current= current_amount
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
          # p "TRANSACTION: #{self.inspect}"
      end
   end
   
end
