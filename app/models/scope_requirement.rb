class ScopeRequirement < ActiveRecord::Base
  include ActiveModel::Validations

  attr_accessible :field, :value, :scope_id

  belongs_to :scope

  class FieldValidator < ActiveModel::EachValidator
  	def validate_each(record, attribute, value)
      record.errors.add attribute, "Not a valid field name" unless (value && Project.new.respond_to?(value))
    end
  end

  validates :field, field: true

end
