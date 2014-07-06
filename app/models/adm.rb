class Adm < ActiveRecord::Base
  attr_accessible :code, :name, :level, :geometry_id, :parent_id

  has_one :geometry, foreign_key: "adm_code", primary_key: "code"
  has_many :geocodes
  has_many :children, class_name: "Adm", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Adm"

  def get_ancestors(include_child = false)
    result = []
    c = self
    if include_child
      result.append(c)
    end
    while c.parent
      result.unshift(c.parent)
      c = c.parent
    end
    result = result.sort_by {|u| u.level}.reverse
    result
  end

  searchable do
    text :name
    integer :level
  end
  handle_asynchronously :solr_index, queue: 'indexing', priority: 50
  handle_asynchronously :solr_index!, queue: 'indexing', priority: 50

  def remove_from_index_with_delayed
    Delayed::Job.enqueue RemoveIndexJob.new(record_class: self.class.to_s, attributes: self.attributes), queue: 'indexing', priority: 50
  end
  alias_method_chain :remove_from_index, :delayed
end
