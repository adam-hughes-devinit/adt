module GeospatialSearchHelper
  include AggregatesHelper

  def geospatial_search_ajax
    file = File.read("public/dashboard_geojson.json")
    @feature_collection = JSON.parse(file)
    if params["search"]!=""
      if params["search"].scan(/(?:\(.*?\))+/)[0].nil? || params["search"].scan(/(?:\(.*?\))+/)[0] =="(keyword)"
        search = Project.solr_search do
          keywords params["search"].split(/(?:\(.*?\))+/)[0] do
            fields(:description, :title => 2.0)
          end
          with :active_string, 'Active'
          with(:geocodes).greater_than(0)
        end
        full_result_ids = search.results.map(&:id)
        unless @feature_collection.nil?
          i = 0
          while i < @feature_collection["features"].length do
            unless full_result_ids.include? @feature_collection["features"][i]["properties"]["project_id"]
              @feature_collection["features"].delete_at(i)
            else
              i += 1
            end
          end
          render :json => @feature_collection
        end
      elsif params["search"].scan(/(?:\(.*?\))+/)[0].start_with?("(ADM")
        search = Adm.solr_search do
          keywords params["search"].split(/(?:\(.*?\))+/)[0] do
            fields(:name)
          end
          paginate :page => 1, :per_page => 10000
          with :level, params["search"].scan(/(?:\(.*?\))+/)[0].split(/(\d+)/)[1] || [0,1,2]
        end
        geocodes = []
        geocodes.concat(search.results.map(&:geocodes).flatten.map(&:id))
        geocodes.concat(search.results.map(&:children).flatten.map(&:geocodes).flatten.map(&:id))
        geocodes.concat(search.results.map(&:children).flatten.map(&:children).flatten.map(&:geocodes).flatten.map(&:id))
        unless @feature_collection.nil?
          i = 0
          while i < @feature_collection["features"].length do
            unless geocodes.include? @feature_collection["features"][i]["properties"]["geo_code_id"]
              @feature_collection["features"].delete_at(i)
            else
              i += 1
            end
          end
          render :json => @feature_collection
        end
      elsif params["search"].scan(/(?:\(.*?\))+/)[0].start_with?("(GEO")
        searchGeoName = Geocode.solr_search do
          keywords params["search"].split(/(?:\(.*?\))+/)[0] do
            fields(:geo_name)
          end
          paginate :page => 1, :per_page => 10000
        end
        geocodes = []
        geocodes.concat(searchGeoName.results.map(&:id))
        unless @feature_collection.nil?
          i = 0
          while i < @feature_collection["features"].length do
            unless geocodes.include? @feature_collection["features"][i]["properties"]["geo_code_id"]
              @feature_collection["features"].delete_at(i)
            else
              i += 1
            end
          end
          render :json => @feature_collection
        end
      else
        search = Project.solr_search do
          keywords params["search"].split(/(?:\(.*?\))+/)[0] do
            fields(:description, :title => 2.0)
          end
          with :active_string, 'Active'
          with(:geocodes).greater_than(0)
        end
        full_result_ids = search.results.map(&:id)
        unless @feature_collection.nil?
          i = 0
          while i < @feature_collection["features"].length do
            unless full_result_ids.include? @feature_collection["features"][i]["properties"]["project_id"]
              @feature_collection["features"].delete_at(i)
            else
              i += 1
            end
          end
          render :json => @feature_collection
        end
      end
    else
      render :json => @feature_collection
    end
  end

  def json_completion_ajax
    search = Adm.solr_search do
      keywords params['keywords'].nil??nil:params['keywords']+' OR '+params['keywords']+'*' do
        fields(:name)
      end
    end
    searchGeoName = GeoName.solr_search do
      keywords params['keywords'].nil??nil:params['keywords']+' OR '+params['keywords']+'*' do
        fields(:name)
      end
    end
    i = 0
    len = searchGeoName.results.first(4).length
    @bucket = []
    @bucket << params['keywords'] + " (keyword)"
    while i < len
      @bucket << searchGeoName.results[i]["name"] + " (GEO: " + [searchGeoName.results[i]].map(&:location_type)[0]["name"] + ")"
      i += 1
    end
    i = 0
    len = search.results.first(5).length
    while i < len
      @bucket << search.results[i]["name"] + " (ADM" + search.results[i]["level"].to_s + ")"
      i += 1
    end
    render :json => @bucket.flatten
  end

end