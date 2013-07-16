class Geopolitical < ActiveRecord::Base
  attr_accessible :percent, :project_id, 
  :recipient_id,  :subnational, :recipient, :region_id

  include ProjectAccessory

  belongs_to :recipient, class_name: "Country"
  delegate :name, :iso3, :iso2, to: :recipient, allow_nil: true, prefix: true

  def to_iati
  	%{
  		<recipient-country code="#{recipient_iso2}" percentage="#{percent}">
	  		#{recipient_name}
	  	</recipient-country>
	  	#{subnational.present? ? %{
	  		<location>
	  			<name>#{subnational}</name>
	  			<administrative country="#{recipient_iso2}">
	  				#{subnational}, #{recipient_name}
	  			</administrative>
	  		</location>
	  		}
	  	: "" }
  	}
  end

end
