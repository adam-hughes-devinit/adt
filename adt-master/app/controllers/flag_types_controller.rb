class FlagTypesController < CodesController
skip_before_filter :signed_in_user, only: [:create]
before_filter {|c| create_local_variables "FlagType", "Flag Type", has_projects: false}

end
