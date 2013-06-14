class ScopeChannel < ActiveRecord::Base
  attr_accessible :scope_id, :filters, 
  :scope_filters_attributes, :scope_filters

  #after_initialize :build_scope_channel_scaffold
  
  def filters
    scope_filters.map { |f| { "field" => f.field, "values" => f.values } }
  end


  belongs_to :scope
  has_many :scope_filters, dependent: :destroy
  accepts_nested_attributes_for :scope_filters, allow_destroy: true #,  :reject_if => proc 

  def build_scope_channel_scaffold
    self.scope_filters.build
    self.scope_filters.each do |f|
      f.build_scope_filter_scaffold
    end
    
    self
  end

end
