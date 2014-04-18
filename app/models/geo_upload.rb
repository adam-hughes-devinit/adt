class GeoUpload < ActiveRecord::Base
  attr_accessible :record_count, :csv, :log, :log_errors, :critical_errors, :active

  has_attached_file :csv
  has_attached_file :log

  validates_attachment :csv, :presence => true,
                       :content_type => { :content_type => "text/csv" }

  validates :active,
            :inclusion => {
                :in => [false],
                message: "Can't activate Upload with Critical Errors!  Resolve the issue in the CSV (or contact site admin), then delete this record and re-upload the CSV."
            },
            if: :has_errors?

  has_many :geocodes

  def has_errors?
    self.critical_errors > 0
  end

  def self.find_adm(lonlat, adm_level, logfile, geocode, record_stats)
    adm = Adm.where{level == adm_level}.joins{geometry}.where{st_contains(st_collectionextract(geometries.the_geom,3), lonlat)}.first
    if !adm.nil? # prevents crash if no adm match is found.
      geocode[:adm_id] = adm.id
      geocode[:geometry_id] = adm.geometry.id
    else
       # Sometimes point doesn't reside inside an adm (usually because its in water).
       # This finds the nearest adm to the point.
      closest_adm = Adm.where{level == adm_level}.joins{geometry}.select{[st_distance(st_collectionextract(geometries.the_geom,3), lonlat).as('distance'), id, geometries.id.as('geometry_id')]}.order('distance').first
      #closest_adm = Adm.find(chosen_adm.adm_id)
      if !closest_adm.nil? # prevents crash if no adm match is found.
        geocode[:adm_id] = closest_adm.id
        geocode[:geometry_id] = closest_adm.geometry_id

        logfile.write("Info: geocode_id #{geocode.id}: Could not find Adm, so we used the closest one.\n")
        record_stats["created_adm"] += 1
      else
        logfile.write("Warning: geocode_id #{geocode.id}: Could not find Adm\n")
        record_stats["missing_adms"] += 1
      end
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

    # Did saves this way to prevent lost records if an error occurs.
    geo_name.save
    geocode[:geo_name_id] = geo_name.id
    geocode.save

    return geocode
  end

  def self.csv_to_database(chunk, geo_upload, logfile, record_stats)
    chunk.each do |record|
      record_stats["record_total"] += 1
      existing_geocode = Geocode.joins(:geo_name).where(project_id: record[:project_id], geo_name: {code: record[:geo_name_id]} ).first
      if existing_geocode.nil?
        record_stats["uploaded_record_count"] += 1
        geocode = Geocode.create(project_id: record[:project_id],
                                 precision_id: record[:precision_id].round,
                                 geo_upload_id: geo_upload.id)

        location_type = LocationType.find_by_name(record[:location_type])

        # We don't want duplicate geo_names.
        # We assume that new is better.
        # So new geo_name info should replace old geo_names with the same code.
        old_geo_name = GeoName.find_by_code(record[:geo_name_id])
        if !old_geo_name.nil?
          geocode = GeoUpload.update_geo_name(geocode, record, location_type, old_geo_name)
        else
          geo_name = GeoName.new
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
          geocode = GeoUpload.find_adm(lonlat, 2, logfile, geocode, record_stats)

        elsif record[:precision_id] == 4  # its an adm1
          geocode = GeoUpload.find_adm(lonlat, 1, logfile, geocode, record_stats)

        elsif record[:precision_id] == 6 # its an adm0
          geocode = GeoUpload.find_adm(lonlat, 0, logfile, geocode, record_stats)

        elsif record[:precision_id] == 8  # its an adm0
          geocode = GeoUpload.find_adm(lonlat, 0, logfile, geocode, record_stats)
        else
           # It's a [5,7,9] precision code. Put it in the database, but doesn't get a geometry.
          logfile.write("Info: geocode_id #{geocode.id}: Deprecated precision code\n")
          record_stats["deprecated_precisions"] += 1
        end

        geocode.save
      else
        logfile.write("Info: geocode_id #{existing_geocode.id}: This geocode already exists\n")
        record_stats["duplicate_geocodes"] += 1
      end
    end

    return record_stats
  end
end
