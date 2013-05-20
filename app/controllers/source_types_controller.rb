class SourceTypesController < CodesController
before_filter {|c| create_local_variables "SourceType", "Source Type"}

end
