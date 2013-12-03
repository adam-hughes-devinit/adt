class Person < ActiveRecord::Base
  belongs_to :position
  attr_accessible :bio, :email, :first_name, :last_name, :title, :avatar, :position_id, :current_team_member

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :avatar
  validates_presence_of :email
  validates_presence_of :position
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
end
