class IntentsController < CodesController
before_filter {|c| create_local_variables "Intent", "Intent"}

end
