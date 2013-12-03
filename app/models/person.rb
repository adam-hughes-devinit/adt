class Person < ActiveRecord::Base
  belongs_to :position
  attr_accessible :bio, :email, :first_name, :last_name, :title, :avatar, :position_id

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }
end
