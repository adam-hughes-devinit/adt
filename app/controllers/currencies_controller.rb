class CurrenciesController < CodesController
before_filter {|c| create_local_variables "Currency", "Currency"}

end
