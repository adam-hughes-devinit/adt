class OrganizationsController < CodesController
  before_filter {|c| create_local_variables "Organization", "Organization"}
end
