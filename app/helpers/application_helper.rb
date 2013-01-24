require 'active_support/inflector'
module ApplicationHelper

	PROJECT_ACCESSORY_OBJECTS = ['Transaction', 'Geopolitical', 'Source', 'ParticipatingOrganization', 'Contact','LoanDetail']
	
	def link_to_remove_fields(name, f)
		f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
	end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", class: "span12")
  end
  
  def project_detail_flags(flaggable_type_name)
  	Flag.find_all_by_flaggable_id_and_flaggable_type(@project.id, flaggable_type_name) || []
	end 

end
