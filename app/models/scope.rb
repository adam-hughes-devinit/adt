class Scope < ActiveRecord::Base
	include IndexAndCacheHelper
	include ScopesHelper	
	include ScopeToQueryParams
	include ScopeIncludesProject
 
	attr_accessible :description, :name, :symbol, :channels
	# :scope_channels, :scope_channels_attributes
	serialize :channels, Array

	# after_save :remake_scopes_hash
	after_destroy :remake_scopes_hash

	# after_save :touch_projects
	after_destroy :touch_projects

	def serialized_channels
		scope_channels.map { |c| c.filters }
	end



	has_many :scope_channels, dependent: :destroy
	accepts_nested_attributes_for :scope_channels, allow_destroy: true 

	validates :name, presence: true, uniqueness: true
	validates :symbol, presence: true, uniqueness: true,
		format: { with: /^[a-z\_]+$/,
				 message: "Use only lowercase letters and underscores." }

	def build_scope_scaffold
		#fills out a skeleton, returns self
		self.name = 'Scope Name'
		self.symbol = 'scope_symbol'
		self.description = 'This is the description of the scope.'
		self.channels = []

		self
	end

	def as_json(options={})
		super(
			only: [:id,:name, :symbol, :description, :channels]
		) 
	end


	def touch_projects
		start = Time.new

		p "Touch projects for #{self.name} at #{start}"
	 	
		Project.all.each{ |p| p.delay.save }


	end
	

	

end
