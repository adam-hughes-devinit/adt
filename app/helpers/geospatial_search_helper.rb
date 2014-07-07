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
          paginate :page => 1, :per_page => 10000
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
          if full_result_ids.length==0
            full_result_ids = ["a"]
          end
          paginatedSearch = Project.solr_search do
            with(:id).any_of(full_result_ids)
            paginate :page => params[:page] || 1, :per_page => 5
            order_by(:title,:asc)
          end
          @page = {}
          @page["query"] = params["search"]
          @page["data"] = paginatedSearch.results
          @page["current"] = paginatedSearch.results.current_page
          @page["entries"] = paginatedSearch.results.total_entries
          @page["pages"] = paginatedSearch.results.total_pages
          @page["features"] = @feature_collection
          @page["ids"] = full_result_ids
          render :json => @page
        end
      elsif params["search"].scan(/(?:\(.*?\))+/)[0].start_with?("(ADM")
        search = Adm.solr_search do
          keywords params["search"].split(/(?:\(.*?\))+/)[0].split(/\A[*]+/) do
            fields(:name)
          end
          paginate :page => 1, :per_page => 10000
          with :level, params["search"].scan(/(?:\(.*?\))+/)[0].split(/(\d+)/)[1] || [0,1,2]
        end
        geocodes = []
        geocodes.concat(search.results.map(&:geocodes).flatten)
        geocodes.concat(search.results.map(&:children).flatten.map(&:geocodes).flatten)
        geocodes.concat(search.results.map(&:children).flatten.map(&:children).flatten.map(&:geocodes).flatten)
        full_result_ids = geocodes.map(&:project_id)
        geocodes = geocodes.map(&:id)
        unless @feature_collection.nil?
          i = 0
          while i < @feature_collection["features"].length do
            unless geocodes.include? @feature_collection["features"][i]["properties"]["geo_code_id"]
              @feature_collection["features"].delete_at(i)
            else
              i += 1
            end
          end
          if full_result_ids.length==0
            full_result_ids = ["a"]
          end
          paginatedSearch = Project.solr_search do
            with(:id).any_of(full_result_ids)
            paginate :page => params[:page] || 1, :per_page => 5
            order_by(:title,:asc)
          end
          @page = {}
          @page["query"] = params["search"]
          @page["data"] = paginatedSearch.results
          @page["current"] = paginatedSearch.results.current_page
          @page["entries"] = paginatedSearch.results.total_entries
          @page["pages"] = paginatedSearch.results.total_pages
          @page["features"] = @feature_collection
          @page["ids"] = full_result_ids
          render :json => @page
        end
      elsif params["search"].scan(/(?:\(.*?\))+/)[0].start_with?("(ID")
        search = Project.solr_search do
          with(:id).equal_to(params["search"].split(/(?:\(.*?\))+/)[0])
          with :active_string, 'Active'
          with(:geocodes).greater_than(0)
          paginate :page => 1, :per_page => 10000
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
          if full_result_ids.length==0
            full_result_ids = ["a"]
          end
          paginatedSearch = Project.solr_search do
            with(:id).any_of(full_result_ids)
            paginate :page => params[:page] || 1, :per_page => 5
            order_by(:title,:asc)
          end
          @page = {}
          @page["query"] = params["search"]
          @page["data"] = paginatedSearch.results
          @page["current"] = paginatedSearch.results.current_page
          @page["entries"] = paginatedSearch.results.total_entries
          @page["pages"] = paginatedSearch.results.total_pages
          @page["features"] = @feature_collection
          @page["ids"] = full_result_ids
          render :json => @page
        end
      else
        search = Project.solr_search do
          keywords params["search"].split(/(?:\(.*?\))+/)[0] do
            fields(:description, :title => 2.0)
          end
          with :active_string, 'Active'
          with(:geocodes).greater_than(0)
          paginate :page => 1, :per_page => 10000
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
          if full_result_ids.length==0
            full_result_ids = ["a"]
          end
          paginatedSearch = Project.solr_search do
            with(:id).any_of(full_result_ids)
            paginate :page => params[:page] || 1, :per_page => 5
            order_by(:title,:asc)
          end
          @page = {}
          @page["query"] = params["search"]
          @page["data"] = paginatedSearch.results
          @page["current"] = paginatedSearch.results.current_page
          @page["entries"] = paginatedSearch.results.total_entries
          @page["pages"] = paginatedSearch.results.total_pages
          @page["features"] = @feature_collection
          @page["ids"] = full_result_ids
          render :json => @page
        end
      end
    else
      paginatedSearch = Project.solr_search do
        with :active_string, 'Active'
        with(:geocodes).greater_than(0)
        paginate :page => params[:page] || 1, :per_page => 5
        order_by(:title,:asc)
      end
      searchTotal = Project.solr_search do
        with :active_string, 'Active'
        with(:geocodes).greater_than(0)
        paginate :page=>1, :per_page =>10000
        order_by(:title,:asc)
      end
      @page = {}
      @page["query"] = params["search"]
      @page["data"] = paginatedSearch.results
      @page["current"] = paginatedSearch.results.current_page
      @page["entries"] = paginatedSearch.results.total_entries
      @page["pages"] = paginatedSearch.results.total_pages
      @page["features"] = @feature_collection
      @page["ids"] = searchTotal.results.map(&:id)
      render :json => @page
    end
  end

  def json_completion_ajax
    search = Adm.solr_search do
      keywords params['keywords'].nil??nil:params['keywords']+' OR '+params['keywords']+'*' do
        fields(:name)
      end
    end
    @bucket = []
    i = 0
    len = search.results.first(5).length
    while i < len
      levelHuman = search.results[i]["level"]==0?"Country-level":search.results[i]["level"]==1?"State-level":"District-level"
      @bucket << search.results[i]["name"] + " (ADM" + search.results[i]["level"].to_s + ": " + levelHuman + ")"
      i += 1
    end
    @bucket << params['keywords'] + " (keyword)"
    render :json => @bucket.flatten
  end

  def geo_paginated_search_ajax
    paginatedSearch = Project.solr_search do
      with(:id).any_of(params[:ids] || ["a"])
      paginate :page => params[:page] || 1, :per_page => 5
      order_by(:title,:asc)
    end
    @page = {}
    @page["data"] = paginatedSearch.results
    @page["current"] = paginatedSearch.results.current_page
    @page["entries"] = paginatedSearch.results.total_entries
    @page["pages"] = paginatedSearch.results.total_pages
    @page["ids"] = params[:ids] || ["a"]
    render :json => @page
  end

  def micro_project_page_ajax
    searchProject = Project.solr_search do
      with(:id).equal_to(params[:id] || "a")
      with(:geocodes).greater_than(0)
      paginate :page => 1, :per_page => 1
    end
    adms = searchProject.results.map(&:geocodes).flatten.map(&:adm)
    geocodes = searchProject.results.map(&:geocodes).flatten
    geonames = searchProject.results.map(&:geocodes).flatten.map(&:geo_name)
    i = 0
    len = geocodes.length
    @bucket = []
    while i < len do
      obj = {}
      unless adms[i].nil?
        obj["adm_level"] = adms[i]["level"]
        obj["adm_code"] = adms[i]["code"]
        obj["adm_name"] = adms[i]["name"]
        if adms[i]["level"]==0
          obj["geoTree"] = [adms[i]["name"]]
        elsif adms[i]["level"]==1
          obj["geoTree"] = [[adms[i]].map(&:parent)[0]["name"],adms[i]["name"]]
        elsif adms[i]["level"]==2
          obj["geoTree"] = [[adms[i]].map(&:parent).flatten.map(&:parent)[0]["name"],[adms[i]].map(&:parent)[0]["name"],adms[i]["name"]]
        else
          obj["geoTree"] = [adms[i]["name"]]
        end
      else
        obj["adm_level"] = nil
        obj["geoTree"] = nil
        obj["adm_code"] = nil
        obj["adm_name"] = nil
      end
      obj["geo_code_id"] = geocodes[i]["id"]
      obj["project"] = searchProject.results.first
      obj["precision_id"] = geocodes[i]["precision_id"]
      obj["geo_name"] = geonames[i]["name"]
      obj["lat"] = geonames[i]["latitude"]
      obj["lon"] = geonames[i]["longitude"]
      obj["location_type"] = [geonames[i]].map(&:location_type)[0]["name"]
      @bucket << obj
      i += 1
    end
    render :json => @bucket
  end
end