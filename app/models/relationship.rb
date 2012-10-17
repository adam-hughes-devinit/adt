class Relationship < ActiveRecord::Base
  attr_accessible :followed_id, :followed_type, :follower_id
end
