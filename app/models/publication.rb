class Publication < ActiveRecord::Base
  attr_accessible :author, :date, :description, :location, :name, :publication_type_id, :publication_type,
                  :publisher, :type, :url

  belongs_to :publication_type
end
