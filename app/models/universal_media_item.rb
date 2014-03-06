class UniversalMediaItem < ActiveRecord::Base
  attr_accessible :media

  has_attached_file :media, :styles => { :large => "500x500>", :medium => "320x320>", :thumb => "100x100>" }
end
