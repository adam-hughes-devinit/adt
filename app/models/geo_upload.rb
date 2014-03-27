class GeoUpload < ActiveRecord::Base
  attr_accessible :record_count, :csv

  has_attached_file :csv

  validates_attachment :csv, :presence => true,
                       :content_type => { :content_type => "text/csv" }

  has_many :geocodes
end
