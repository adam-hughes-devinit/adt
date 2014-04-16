class GeoUpload < ActiveRecord::Base
  attr_accessible :record_count, :csv, :log, :log_errors

  has_attached_file :csv
  has_attached_file :log

  validates_attachment :csv, :presence => true,
                       :content_type => { :content_type => "text/csv" }

  has_many :geocodes#, :dependent => :destroy

  #accepts_nested_attributes_for :geocodes, allow_destroy: true

  def self.find_adm(lonlat, adm_level, geocode)
    adm = Adm.where{level == adm_level}.joins{geometry}.where{st_contains(st_collectionextract(geometries.the_geom,3), lonlat)}.first
    if !adm.nil? # prevents crash if no adm match is found. Having world adms should fix this.
      geocode[:adm_id] = adm.id
      geocode[:geometry_id] = adm.geometry.id
    else
      logfile.write("Warning: geocode_id #{geocode.id}: Could not find Adm\n")
      geo_upload.log_errors += 1
    end

    return geocode
  end

  def self.update_geo_name(geocode, record, location_type, geo_name)
    geo_name[:name] = record[:geo_name]
    geo_name[:code] = record[:geo_name_id]
    geo_name[:latitude] = record[:latitude]
    geo_name[:longitude] = record[:longitude]

    # Determine location type for geo_name
    if !location_type.nil?
      geo_name[:location_type_id] = location_type.id
    end

    geo_name.save
    geocode[:geo_name_id] = geo_name.id

    return geocode

  end

  # TODO: Handle duplicate geocodes from previous uploads (perhaps use unique (project_id, geo_name_id))
  # TODO: If geocodes have no adms for non-precision 1's and 2's, find nearest adm and use that.
  # TODO: Create log file associated with geo_upload. Include notification that has number of errors with geo_upload
  # TODO: Add publish variable to geo upload for all geocodes.
  # TODO: Handle precision codes (5, 7 , 9)
  # TODO: Error handling for edges cases. Include notifications for user.                                                                                                                                                                                            Error handling for edges cases. Include notifications for user.
  ## Can't find adm for non-precision 1's and 2's
  ## Non-unique (project_id, geo_name_id)
  ## No geo_name provided (may not be necessary).
  ## No lat/lon provided (may not be necessary).
  ## Update Log time Watch Duplicate Copy Move Delete

  def self.csv_to_database(chunk, geo_upload, logfile)
    chunk.each do |record|
      existing_geocode = Geocode.joins(:geo_name).where(project_id: record[:project_id], geo_name: {code: record[:geo_name_id]} ).first
      if existing_geocode.nil?
        geo_upload.record_count += 1
        geocode = Geocode.create

        geocode[:precision_id] = record[:precision_id].round
        geocode[:project_id] = record[:project_id]
        geocode[:geo_upload_id] = geo_upload.id

        location_type = LocationType.find_by_name(record[:location_type])

        # We don't want duplicate geo_names.
        # We assume that new is better.
        # So new geo_name info should replace old geo_names with the same code.
        old_geo_name = GeoName.find_by_code(record[:geo_name_id])
        if !old_geo_name.nil?
          geocode = GeoUpload.update_geo_name(geocode, record, location_type, old_geo_name)
        else
          geo_name = GeoName.create
          geocode = GeoUpload.update_geo_name(geocode, record, location_type, geo_name)
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
        else
          logfile.write("Info: geocode_id #{geocode.id}: Deprecated precision code\n")
          geo_upload.log_errors += 1
        end

        geocode.save
      else
        logfile.write("Info: geocode_id #{existing_geocode.id}: This geocode already exists\n")
        geo_upload.log_errors += 1
      end
    end
    #return geo_upload.record_count, logfile
    return geo_upload.record_count
  end
end
