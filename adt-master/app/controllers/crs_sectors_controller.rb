class CrsSectorsController < CodesController
  before_filter {|c| create_local_variables "CrsSector", "CRS Sector", 
                                            {has_projects: true}}
end
