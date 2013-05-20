class VersionsController < ApplicationController
	def revert
		@version = Version.find_by_id(params[:id])
		
		if @version.item_type == "Project"
			revert_project
		else 
			if @version.reify
				@version.reify.save!
			else 
				@version.item.destroy
			end
		end
		
		link_name = params[:redo] == "true" ? "Undo" : "Redo"
		link = view_context.link_to(link_name, revert_version_path(@version.next, :redo => !params[:redo] ), method: :post)
		flash[:success] = "Undid #{@version.event}. #{link}"
		redirect_to :back 
	end

	def index
		@feed = Version.order("created_at desc").paginate(page: params[:page], per_page: 50)
	end
	
	private
		def revert_project
			project = @version.reify
			accessories = JSON.parse(@version.accessories)
			accessories.each do |acc_type, values|
			project.send("#{acc_type.pluralize}").clear
			
				values.each do |acc_object|
					acc_object.delete("id")
					acc_object.delete("created_at")
					acc_object.delete("updated_at")
					project.send("#{acc_type}s") << acc_type.camelize.constantize.new(acc_object)
				end
			end
			project.save!
		end


end
