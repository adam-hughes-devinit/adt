class SectorsController < CodesController
  before_filter {|c| create_local_variables "Sector", "Sector"}

end
