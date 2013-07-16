class OrganizationsController < CodesController
  before_filter {|c| create_local_variables "Organization", "Organization"}

  extend Typeaheadable
  enable_typeahead Organization
  
  def all_json
    render json: Organization.organizations_hash
  end
  
  # def merge 

  def merge!
  	this_organization = Organization.find(params[:organization_id])
  	other_organization = Organization.find(params[:other_organization_id])


  	this_organization.devour! other_organization
  	
  	flash[:success] = "Merged Organization ##{params[:other_organization_id]} into Organization ##{params[:organization_id]}"
  	redirect_to this_organization

  end

end
