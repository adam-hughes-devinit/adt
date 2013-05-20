class StatusesController < CodesController
before_filter {|c| create_local_variables "Status", "Status"}

end
