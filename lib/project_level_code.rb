module ProjectLevelCode
  	extend ActiveSupport::Concern

	included do
		has_paper_trail
		default_scope order: "name"	
		has_many :projects
	end

end
