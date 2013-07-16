class ParticipatingOrganization < ActiveRecord::Base
  attr_accessible :organization_id, 
  :role_id, :role, :origin_id, :origin, :project_id, :organization
  include ProjectAccessory

  delegate :name, to: :organization, allow_nil: true, prefix: true
  delegate :organization_type_name, to: :organization, allow_nil: true
  delegate :organization_type_iati_code, to: :organization, allow_nil: true

  delegate :name, to: :role, allow_nil: true, prefix: true
  delegate :name, to: :origin, allow_nil: true, prefix: true
  belongs_to :organization
  belongs_to :role
  belongs_to :origin


  def to_iati
    %{<participating-org role="#{role_name}" type="#{organization_type_iati_code}">
        #{organization_name}
      </participating-org>
    }
  end


end
