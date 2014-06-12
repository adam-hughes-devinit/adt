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
  end
end
