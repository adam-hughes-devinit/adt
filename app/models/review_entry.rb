class ReviewEntry < ActiveRecord::Base
  attr_accessible :serialized_item, :status

  def add_item(review_item)
    hash = review_item.attributes
    hash[:class_name] = review_item.class.name
    self.serialized_item = hash.to_yaml
    self.save!
  end

  def item
    hash = YAML.load(serialized_item)
    case hash[:class_name]
    when "Comment"
      Comment.new(content: hash["content"], 
                  project_id: hash["project_id"],
                  name: hash["name"],
                  email: hash["email"])
    when "Flag"
      Flag.new(flag_type_id: hash["flag_type_id"],
               owner_id: hash["owner_id"],
               source: hash["source"],
               comment: hash["comment"])
    end
  end
  
end
