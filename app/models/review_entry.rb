class ReviewEntry < ActiveRecord::Base
  attr_accessible :serialized_item, :status

  def item
    @item = YAML.load(serialized_item)
  end
end
