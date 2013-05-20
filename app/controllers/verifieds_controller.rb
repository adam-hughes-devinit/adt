class VerifiedsController < CodesController
 before_filter {|c| create_local_variables "Verified", "Verified"}

 end
