class DocumentTypesController < CodesController
before_filter {|c| create_local_variables "DocumentType", "Document Type"}
end
