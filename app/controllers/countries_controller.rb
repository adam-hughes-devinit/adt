class CountriesController < CodesController
before_filter {|c| create_local_variables "Country", "Country"}
end
