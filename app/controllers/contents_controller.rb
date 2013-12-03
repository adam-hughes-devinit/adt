class ContentsController < CodesController
skip_before_filter :signed_in_user, only: [:show_by_name, :search]

before_filter { |c| create_local_variables "Content", "Content", has_projects: false }
extend Typeaheadable
enable_typeahead Content, value_method: :to_english

	def show_by_name
		@content = Content.find_by_name(params[:name])
  end

  def show_complex_content
    @complex_name = params[:complex_name]
  end

	def search 
		@search = Content.search do
			fulltext params[:search]
		end
		@contents = @search.results

		render json: @contents.first(10).map {|c| {type: "Content", value: c.id, tokens: c.name.split(' '), english: c.name} }
	end
	

end
