require 'active_support/inflector'
module ApplicationHelper

  PROJECT_ACCESSORY_OBJECTS = ['Transaction', 'Geopolitical', 'Source', 
    'ParticipatingOrganization', 'Contact','LoanDetail']

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name.html_safe, "remove_fields(this)")
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("fields_for_" + association.to_s.singularize, :f => builder)
    end
    link_to_function(
      "#{name}".html_safe, 
      "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")",
      class: "add-one")
  end

  def project_detail_flags(flaggable_type_name)
    Flag.find_all_by_flaggable_id_and_flaggable_type(@project.id, flaggable_type_name) || []
  end 

  # Gives a link to the related project from an object
  def link_to_related_project(object)
    url = "/projects/"
    rp = related_project(object)
    url << rp.id.to_s unless rp.nil?
  end

  def related_project(object)
    if object.respond_to?(:project)
      object.project
    elsif object.respond_to?(:project_id)
      Project.find(object.project_id)
    elsif object.instance_of?(Project)
      object
    end
  end

end
