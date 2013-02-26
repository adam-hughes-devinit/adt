class ScopeFilter < ActiveRecord::Base
  attr_accessible :field, :scope_channel_id,
  :scope_filter_values_attributes,
  :scope_filter_values

  #after_initialize :build_scope_filter_scaffold

  validates :field, presence: true

  def values
  	scope_filter_values.map(&:value)
  end

  def required_values
    values.select { |v| v !~ /^not/}
  end

  def disallowed_values
    values.select { |v| v =~ /^not/}.map{ |v| v.gsub(/^not\s/, '')}
  end

  belongs_to :scope_channel
  has_many :scope_filter_values, dependent: :destroy
  accepts_nested_attributes_for :scope_filter_values, allow_destroy: true #,  :reject_if => proc 

  # Fields have to be
  validates :field, 
    inclusion: { in: (WORKFLOW_FACETS + FACETS).map {|f| f[:sym].to_s},
    message: "Not a valid field!"}

  def build_scope_filter_scaffold
  	self.scope_filter_values.build
  end
end
