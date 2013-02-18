class Scope < ActiveRecord::Base
	@@scope_type = %w(union intersect)
	attr_accessible :hint, :name, :symbol, :type

	has_many :scope_requirements

	def to_sym
		symbol.to_sym
	end


	def scope_types
		@@scope_type
	end

	validates :symbol, presence: true, uniqueness: true
	validates :name, presence: true, uniqueness: true
	validates_inclusion_of :type, in: @@scope_type, message: "Must be one of: #{Scope.new.scope_types.join ', '}"


end
