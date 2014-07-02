class GeoUpload < ActiveRecord::Base
  attr_accessible :record_count, :csv, :log, :log_errors, :critical_errors, :active

  has_attached_file :csv
  has_attached_file :log

  validates_attachment :csv, :presence => true,
                       :content_type => {
                           :content_type => ['text/csv','text/comma-separated-values','text/plain','application/csv',
                                'application/excel','application/vnd.ms-excel','application/vnd.msexcel'] }

  validates_attachment_content_type :log, :content_type => "text/plain"
  #do_not_validate_attachment_file_type :log #uncomment if upgrade paperclip to 4.1


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

  #TODO: Make sure it finds nearest adm, within the correct country. Right now it's just the nearest adm.
    # First add adm_code field to countries table. Then populate it with correct adm0's.
    # Then use a projects recipient country to match up with correct adm0.
    # THen find nearest adm, within the select adm0.
  def self.find_adm(lonlat, adm_level, logfile, geocode, record_stats, include_geometry)
    adm = Adm.where{level == adm_level}.joins{geometry}.where{st_contains(st_collectionextract(geometries.the_geom,3), lonlat)}.first
    if !adm.nil? # prevents crash if no adm match is found.
      geocode[:adm_id] = adm.id
      if include_geometry
        geocode[:geometry_id] = adm.geometry.id
      end
    else
       # Sometimes point doesn't reside inside an adm (usually because its in water).
       # This finds the nearest adm to the point.
      closest_adm = Adm.where{level == adm_level}.joins{geometry}.select{[st_distance(st_collectionextract(geometries.the_geom,3), lonlat).as('distance'), id, geometries.id.as('geometry_id')]}.order('distance').first
      if !closest_adm.nil? # prevents crash if no adm match is found.
        geocode[:adm_id] = closest_adm.id
        if include_geometry
          geocode[:geometry_id] = closest_adm.geometry_id
        end

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
      if !(record[:geo_name_id] and
          record[:project_id] and
          record[:precision_id] and
          record[:longitude] and
          record[:latitude] and
          record[:location_type]).nil?

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

          #puts record

          factory = RGeo::Cartesian.factory(:srid => 4326)
          lonlat = factory.point(record[:longitude], record[:latitude])

          geometry_map = {}
          if record[:precision_id] == 1  # its a point
            geocode = GeoUpload.find_adm(lonlat, 2, logfile, geocode, record_stats, false)

            geometry_map[:the_geom] = RGeo::Feature.cast(lonlat, RGeo::Feature::GeometryCollection)
            new_geometry = Geometry.create ( geometry_map )
            geocode[:geometry_id] = new_geometry.id

          elsif record[:precision_id] == 2  # its a buffer within 25km
            geocode = GeoUpload.find_adm(lonlat, 2, logfile, geocode, record_stats, false)

            lonlat_buff = lonlat.buffer(25000)
            geometry_map[:the_geom] = RGeo::Feature.cast(lonlat_buff, RGeo::Feature::GeometryCollection)

            new_geometry = Geometry.create ( geometry_map )
            geocode[:geometry_id] = new_geometry.id

          elsif record[:precision_id] == 3  # its an adm2
            geocode = GeoUpload.find_adm(lonlat, 2, logfile, geocode, record_stats, true)

          elsif record[:precision_id] == 4  # its an adm1
            geocode = GeoUpload.find_adm(lonlat, 1, logfile, geocode, record_stats, true)

          elsif record[:precision_id] == 6 # its an adm0
            geocode = GeoUpload.find_adm(lonlat, 0, logfile, geocode, record_stats, true)

          elsif record[:precision_id] == 8  # its an adm0
            geocode = GeoUpload.find_adm(lonlat, 0, logfile, geocode, record_stats, true)
          else
             # It's a [5,7,9] precision code. Put it in the database, but it doesn't get a geometry.
            logfile.write("Info: geocode_id #{geocode.id}: Deprecated precision code\n")
            record_stats["deprecated_precisions"] += 1
          end

          geocode.save
        else
          logfile.write("Info: geocode_id #{existing_geocode.id}: This geocode already exists\n")
          record_stats["duplicate_geocodes"] += 1
        end
      else
        logfile.write("Warning: A record is missing required fields. \n")
        record_stats["missing_fields"] += 1
      end
    end
    return record_stats
  end

  def process_csv
    geo_upload = self
    log_path = Rails.root.join('tmp')
    logfile = Tempfile.new('geo_upload.log', log_path)
    logfile.write("Geo Uploads Logfile:\n")
    record_stats = {"record_total" => 0,
                    "uploaded_record_count" => 0,
                    "missing_adms" => 0,
                    "deprecated_precisions" => 0,
                    "duplicate_geocodes" => 0,
                    "created_adm" => 0,
                    "missing_fields" => 0
    }

    SmarterCSV.process(geo_upload.csv.path,
                       {:chunk_size => 100,
                        :remove_unmapped_keys => true,
                        :key_mapping => {:geo_name_id => :geo_name_id,
                                         :geo_name => :geo_name,
                                         :project_id => :project_id,
                                         :precision => :precision_id,
                                         :latitude => :latitude,
                                         :longitude => :longitude,
                                         :location_type => :location_type }
                       }
    ) do |chunk|
      # perhaps refactor to work on geo_upload object
      record_stats = GeoUpload.csv_to_database(chunk, geo_upload, logfile, record_stats)
    end
    geo_upload.record_count = record_stats["uploaded_record_count"]
    geo_upload.log_errors =
        (record_stats["missing_adms"] +
            record_stats["deprecated_precisions"] +
            record_stats["duplicate_geocodes"] +
            record_stats["created_adm"] +
            record_stats["missing_fields"]
        )
    # Any error that could result in corrupted data should be added here.
    # Any critical errors will prevent the user from activating this geo upload.
    geo_upload.critical_errors = record_stats["missing_adms"] + record_stats["missing_fields"]

    if geo_upload.log_errors == 0
      logfile.write("No errors found. Nice!\n")
    end
    logfile.write("\nSummary Statistics:\n")
    logfile.write("#{geo_upload.record_count} out of #{record_stats["record_total"]} records added to the database.\n")
    logfile.write("#{record_stats["missing_adms"]} record has appropriate precision code, but no adm found. Warning: If this is not 0, these Geo Uploads should NOT be active.\n")
    logfile.write("#{record_stats["deprecated_precisions"]} records have a deprecated precision code. Record uploaded, but no geometry was created.\n")
    logfile.write("#{record_stats["duplicate_geocodes"]} records have the same project_id and geo_name_id as existing records. These records were not uploaded.\n")
    logfile.write("#{record_stats["created_adm"]} records did not have adms that should. Used closest adm instead.\n")
    logfile.write("#{record_stats["missing_fields"]} records are missing a required field. The records were not added. Correct them and re-upload. This error may occur if a required field name has changed.\n")
    logfile.read # fixes bug that prevents log file text being saved.
    geo_upload.log = logfile

    geo_upload.save

    # Creates geojson for all existing projects and caches it.
    # Cached data is consumed by to humanity united dashboard.
    @geocodes = Geocode.includes(:adm, :geo_name)
    features = []
    factory = RGeo::GeoJSON::EntityFactory.instance
    @geocodes.each do |g|
      factory_cartesian = RGeo::Cartesian.factory(:srid => 4326)
      lonlat = factory_cartesian.point(g.geo_name.longitude, g.geo_name.latitude)

      features.append(factory.feature(lonlat, nil, {
          geo_code_id: g.id,
          project_id: g.project_id,
          project_year: g.project.year,
          precision_code: g.precision_id,
          adm_code: g.adm_id.nil? ? nil : g.adm.code,
          adm_name: g.adm_id.nil? ? nil : g.adm.name,
          adm_level: g.adm_id.nil? ? nil : g.adm.level,
          geo_name: g.geo_name.name,
          location_type: g.geo_name.location_type.name
      }))
    end
    feature_collection = RGeo::GeoJSON.encode(factory.feature_collection(features))
    #Rails.cache.fetch("dashboard_geojson", expires_in: 48.hours) {feature_collection}
    File.open("public/dashboard_geojson.json","w") do |f|
      f.write(feature_collection.to_json)
    end
  end
  handle_asynchronously :process_csv
end
