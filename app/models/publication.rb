class Publication < ActiveRecord::Base
  attr_accessible :author, :date, :description, :location, :name, :publication_type_id, :publication_type,
                  :publisher, :category, :url

  belongs_to :publication_type

  validates_presence_of :name, :author, :url, :publication_type, :date
  validates_uniqueness_of :name
  validates_format_of :date, :with => /^\d{4}$/i, :allow_blank => true, :message  => "Must be a year"
end
