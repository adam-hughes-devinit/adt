class ReviewEntry < ActiveRecord::Base
  attr_accessible :serialized_item, :status, :ar_model

  def self.add_item(review_item)
    att_hash = review_item.attributes
    @review = ReviewEntry.new(serialized_item: att_hash.to_yaml,
                              ar_model:        review_item.class.name)
    @review.save!
  end

  def item
    att_hash = YAML.load(serialized_item)
    att_hash.delete("id")
    att_hash.delete("updated_at")
    item_obj = ar_model.constantize.new(att_hash)
  end
  
end
