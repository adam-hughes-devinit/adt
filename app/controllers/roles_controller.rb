class RolesController < CodesController
before_filter {|c| create_local_variables "Role", "Role"}
end
