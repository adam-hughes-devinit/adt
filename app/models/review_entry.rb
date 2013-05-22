class ReviewEntry < ActiveRecord::Base
  attr_accessible :serialized_item, :status, :ar_model

  scope :comments, where(ar_model: "Comment")
  scope :flags, where(ar_model: "Flag")
  scope :projects, where(ar_model: "Project")

  def self.add_item(review_item, *options)
    att_hash = review_item.attributes
    options.each do |sym|
      att_hash[sym.to_s] = review_item.send(sym)
    end
    @review = ReviewEntry.new(serialized_item: att_hash.to_yaml,
                              ar_model:        review_item.class.name)
    @review.save!
    AiddataAdminMailer.delay.review_notification(@review)
  end

  def item
    att_hash = YAML.load(serialized_item)
    att_hash.delete("id")
    att_hash.delete("updated_at")
    item_obj = ar_model.constantize.new
    att_hash.each do |key, value|
      sym = (key + "=").to_sym
      item_obj.send(sym, value)
    end
    item_obj
  end
  
end
