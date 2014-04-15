class GeoUpload < ActiveRecord::Base
  attr_accessible :record_count, :csv

  has_attached_file :csv

  validates_attachment :csv, :presence => true,
                       :content_type => { :content_type => "text/csv" }

  has_many :geocodes#, :dependent => :destroy

  #accepts_nested_attributes_for :geocodes, allow_destroy: true

  def self.find_adm(lonlat, adm_level, geocode)
    adm = Adm.where{level == adm_level}.joins{geometry}.where{st_contains(st_collectionextract(geometries.the_geom,3), lonlat)}.first
    if !adm.nil? # prevents crash if no adm match is found. Having world adms should fix this.
      geocode[:adm_id] = adm.id
      geocode[:geometry_id] = adm.geometry.id
    end

    return geocode
  end
  # TODO: Handle duplicate geocodes from previous uploads (perhaps use unique (project_id, geo_name_id))
  # TODO: If geocodes have no adms for non-precision 1's and 2's, find nearest adm and use that.
  # TODO: Error handling for edges cases. Include notifications for user.                                                                                                                                                                                            Error handling for edges cases. Include notifications for user.
  ## Can't find adm for non-precision 1's and 2's
  ## Non-unique (project_id, geo_name_id)
  ## No geo_name provided (may not be necessary).
  ## No lat/lon provided (may not be necessary).
  ## Update Log time Watch Duplicate Copy Move Delete

  def self.csv_to_database(chunk, geo_upload)
    chunk.each do |record|
      geo_upload.record_count += 1
      geocode = {}
      geocode[:precision_id] = record[:precision_id]
      geocode[:project_id] = record[:project_id]
      geocode[:geo_upload_id] = geo_upload.id

      location_type = LocationType.find_by_name(record[:location_type])

      # We don't want duplicate geo_names.
      # We assume that new is better.
      # So new geo_name info should replace old geo_names with the same code.
      old_geo_name = GeoName.find_by_code(record[:geo_name_id])
      if !old_geo_name.nil?
        old_geo_name.name = record[:geo_name]
        old_geo_name.code = record[:geo_name_id]
        old_geo_name.latitude = record[:latitude]
        old_geo_name.longitude = record[:longitude]

        # Determine location type for geo_name
        if !location_type.nil?
          old_geo_name.location_type_id = location_type.id
        end
        old_geo_name.save
        geocode[:geo_name_id] = old_geo_name.id
      else
        # could make this and old_geo_name better if I create a new empty geoname and then update it.
        # Code would be much cleaner.
        geo_name = {}
        geo_name[:name] = record[:geo_name]
        geo_name[:code] = record[:geo_name_id]
        geo_name[:latitude] = record[:latitude]
        geo_name[:longitude] = record[:longitude]

        # Determine location type for geo_name
        if !location_type.nil?
          geo_name[:location_type_id] = location_type.id
        end

        new_geo_name = GeoName.create( geo_name )
        geocode[:geo_name_id] = new_geo_name.id
      end

      puts record

      factory = RGeo::Cartesian.factory
      lonlat = factory.point(record[:longitude], record[:latitude])

      geometry_map = {}
      if record[:precision_id] == 1  # its a point
        geometry_map[:the_geom] = RGeo::Feature.cast(lonlat, RGeo::Feature::GeometryCollection)
        new_geometry = Geometry.create ( geometry_map )
        geocode[:geometry_id] = new_geometry.id

      elsif record[:precision_id] == 2  # its a buffer within 25km
        lonlat_buff = lonlat.buffer(25000)
        geometry_map[:the_geom] = RGeo::Feature.cast(lonlat_buff, RGeo::Feature::GeometryCollection)

        new_geometry = Geometry.create ( geometry_map )
        geocode[:geometry_id] = new_geometry.id

      elsif record[:precision_id] == 3  # its an adm2
        geocode = GeoUpload.find_adm(lonlat, 2, geocode)

      elsif record[:precision_id] == 4  # its an adm1
        geocode = GeoUpload.find_adm(lonlat, 1, geocode)

      elsif record[:precision_id] == 6 # its an adm0
        geocode = GeoUpload.find_adm(lonlat, 0, geocode)

      elsif record[:precision_id] == 8  # its an adm0
        geocode = GeoUpload.find_adm(lonlat, 0, geocode)
      end

      Geocode.create( geocode )
    end
    return geo_upload.record_count
  end
end
