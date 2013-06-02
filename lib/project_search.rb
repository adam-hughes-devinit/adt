module ProjectSearch

	  def origin_name
    participating_organizations.map {|p| p.origin_name || 'Unset'}
  end

  def organization_type_name
    participating_organizations.map {|p|  p.organization_type_name || 'Unset'}
  end

  def role_name
    participating_organizations.map {|p|  p.role_name || 'Unset'}
  end

  def organization_name
    participating_organizations.map { |p|  p.organization_name || 'Unset'}
  end
  
end
