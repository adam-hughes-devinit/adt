class ContentsController < CodesController
skip_before_filter :signed_in_user, only: [:show_by_name]

before_filter { |c| create_local_variables "Content", "Content", has_projects: false }

	def show_by_name
		@content = Content.find_by_name(params[:name])
	end


end
