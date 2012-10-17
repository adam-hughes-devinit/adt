class OdaLikesController < CodesController
  before_filter {|c| create_local_variables "OdaLike", "Oda Like"}
end
