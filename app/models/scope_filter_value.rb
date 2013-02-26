class ScopeFilterValue < ActiveRecord::Base
  attr_accessible :scope_filter_id, :value

  belongs_to :scope_filter
end
