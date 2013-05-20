class OriginsController < CodesController
before_filter {|c| create_local_variables "Origin", "Origin"}
end
