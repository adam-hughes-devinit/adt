class FlowTypesController < CodesController
before_filter {|c| create_local_variables "FlowType", "Flow Type"}
end
