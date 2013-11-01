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

  def must_have_values
    # required values or all non-disallowed values
    values = []

    values += required_values
    
    if (dv = disallowed_values) && dv.length > 0
      whole_dataset = Project.solr_search do
        (ProjectSearch::WORKFLOW_FACETS + ProjectSearch::FACETS).each do |f|
          facet f[:sym]
        end
      end 

      all_other_values = whole_dataset
                .facet(field.to_sym)
                .rows
                .select {|r| !dv.include?(r.value) }
                .map(&:value)
      values += all_other_values
    end  

    values
  end

  def to_project_query_params
    param_string = ""

    must_have_values.each do |value|
      param_string += "&#{field}[]=#{value}"
    end

    param_string.gsub(/\+/, "%2B")
  end

  def to_aggregate_query_params
    param_string = ""

    p field
    if field != 'active_string' &&
      # Agg gives active by default
      aggregate_query_name = AggregatesHelper::WHERE_FILTERS
        .select{|f| f[:sym] == field.to_sym || f[:search_constant_sym] == field.to_sym }[0][:sym].to_s

      param_string += "&#{aggregate_query_name}=#{must_have_values.join(AggregatesHelper::VALUE_DELIMITER)}"
    end

    param_string.gsub(/\+/, "%2B")
  end


  belongs_to :scope_channel
  has_many :scope_filter_values, dependent: :destroy
  accepts_nested_attributes_for :scope_filter_values, allow_destroy: true #,  :reject_if => proc 

  # Fields have to be
  validates :field, 
    inclusion: { in: (ProjectSearch::WORKFLOW_FACETS + ProjectSearch::FACETS).map {|f| f[:sym].to_s},
    message: "Not a valid field!"}

  def build_scope_filter_scaffold
  	self.scope_filter_values.build
  end
end
