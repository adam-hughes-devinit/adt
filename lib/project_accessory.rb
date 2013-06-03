module ProjectAccessory
	extend ActiveSupport::Concern

	included do
		has_paper_trail 
		has_many :flags, as: :flaggable, dependent: :destroy
		accepts_nested_attributes_for :flags
		belongs_to :project
	end
	
end