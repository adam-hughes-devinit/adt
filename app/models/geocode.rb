class Geocode < ActiveRecord::Base
  attr_accessible :geo_name_id, :precision_id, :project_id, :geometry_id, :geo_upload_id, :adm_id

  belongs_to :geo_name
  belongs_to :precision
  belongs_to :project
  belongs_to :geometry
  belongs_to :geo_upload
  belongs_to :adm

  has_many :flags, as: :flaggable, dependent: :destroy
  accepts_nested_attributes_for :flags

  searchable do
    text :geo_name do
      if !geo_name.nil?
        geo_name.name
      end
    end
  end
  handle_asynchronously :solr_index, queue: 'indexing', priority: 50
  handle_asynchronously :solr_index!, queue: 'indexing', priority: 50

  def remove_from_index_with_delayed
    Delayed::Job.enqueue RemoveIndexJob.new(record_class: self.class.to_s, attributes: self.attributes), queue: 'indexing', priority: 50
  end
  alias_method_chain :remove_from_index, :delayed
end
