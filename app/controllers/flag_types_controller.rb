class FlagTypesController < CodesController
before_filter {|c| create_local_variables "FlagType", "Flag Type", has_projects: false}

end
