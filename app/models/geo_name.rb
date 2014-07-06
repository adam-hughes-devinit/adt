class GeoName < ActiveRecord::Base
  attr_accessible :name, :code, :latitude, :longitude, :location_type_id

  has_many :geocodes
  belongs_to :location_type

  searchable do
    text :name
    text :location_type do
      location_type.name
    end
  end
  handle_asynchronously :solr_index, queue: 'indexing', priority: 50
  handle_asynchronously :solr_index!, queue: 'indexing', priority: 50

  def remove_from_index_with_delayed
    Delayed::Job.enqueue RemoveIndexJob.new(record_class: self.class.to_s, attributes: self.attributes), queue: 'indexing', priority: 50
  end
  alias_method_chain :remove_from_index, :delayed
end
