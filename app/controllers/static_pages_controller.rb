class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  include SearchHelper
  include AggregatesHelper
  require 'will_paginate/array'
  def home
    # Gets records for the media viewer
    max_records = 6
    @home_media = get_home_media(max_records)
    project_limit = max_records - @home_media.count()
    if (project_limit > 0)
      @project_media = get_project_media(project_limit)
    else
      @project_media = nil
    end
    render 'home'
  end

  def aggregator
    @aggregator_locals = make_aggregator_locals
    @value_delimiter = AggregateValidators::VALUE_DELIMITER
    render 'aggregate_exporter_page'
  end

  def analyze
    render 'bubbles'
  end

  def downloads
    render 'downloads'
  end

  def codebook
    pdf_data = File.open(Rails.public_path + "/methodology/AidData_MBDC_Methodology_1.0.pdf", "r"){|io| io.read}
    send_data pdf_data, disposition: "inline", :type => 'application/pdf'
  end

  def tuff_codebook
    pdf_data = File.open(Rails.public_path + "/methodology/AidData_TUFF_Methodology.pdf", "r"){|io| io.read}
    send_data pdf_data, disposition: "inline", :type => 'application/pdf'
  end

  def ground_truthing
    pdf_data = File.open(Rails.public_path + "/methodology/AidData_UNUWIDER_Groundtruthing_Paper.pdf", "r"){|io| io.read}
    send_data pdf_data, disposition: "inline", :type => 'application/pdf'
  end

  def aid_conflict_nexus
    pdf_data = File.open(Rails.public_path + "/methodology/aid_conflict_nexus.pdf", "r"){|io| io.read}
    send_data pdf_data, disposition: "inline", :type => 'application/pdf'
  end

  def csv_analyzer
    render 'csv_analyzer'
  end

  def dashboard 
    render 'dashboard'
  end

  def circle_grid
    render "circle_grid"
  end

  def map
    render 'map'
  end

  def geospatial_dashboard
    @file = File.read("public/dashboard_geojson.json")
    @feature_collection = JSON.parse(@file)
    #@feature_collection = Rails.cache.fetch("dashboard_geojson")
    @search = Project.solr_search do
      with :active_string, 'Active'
      paginate :page => 1, :per_page => 5
      order_by(:title,:asc)
    end
    @first_page = {}
    @first_page["data"] = @search.results
    @first_page["current"] = @search.results.current_page
    @first_page["entries"] = @search.results.total_entries
    @first_page["pages"] = @search.results.total_pages
    respond_to do |format|
      format.html { render 'geospatial_dashboard' }
      format.geojson { render json: @feature_collection }
      format.json {render json: @first_page}
    end
  end

  def geospatial_search
    @file = File.read("public/dashboard_geojson.json")
    @feature_collection = JSON.parse(@file)
    if params["search"]!=""
      if params["search"].scan(/(?:\(.*?\))+/)[0].nil? || params["search"].scan(/(?:\(.*?\))+/)[0] =="(keyword)"
        @search = Project.solr_search do
          keywords params["search"].split(/(?:\(.*?\))+/)[0] do
            fields(:description, :title => 2.0)
          end
          with :active_string, 'Active'
        end
        @full_result_ids = @search.results.map(&:id)
        unless @feature_collection.nil?
          @i = 0
          while @i < @feature_collection["features"].length do
            unless @full_result_ids.include? @feature_collection["features"][@i]["properties"]["project_id"]
              @feature_collection["features"].delete_at(@i)
            else
              @i += 1
            end
          end
          render :json => @feature_collection
        end
      elsif params["search"].scan(/(?:\(.*?\))+/)[0].start_with?("(ADM")
        @search = Adm.solr_search do
          keywords params["search"].split(/(?:\(.*?\))+/)[0] do
            fields(:name)
          end
          paginate :page => 1, :per_page => 10000
          with :level, params["search"].scan(/(?:\(.*?\))+/)[0].split(/(\d+)/)[1] || [0,1,2]
        end
        @geocodes = []
        @geocodes.concat(@search.results.map(&:geocodes).flatten.map(&:id))
        @geocodes.concat(@search.results.map(&:children).flatten.map(&:geocodes).flatten.map(&:id))
        @geocodes.concat(@search.results.map(&:children).flatten.map(&:children).flatten.map(&:geocodes).flatten.map(&:id))
        unless @feature_collection.nil?
          @i = 0
          while @i < @feature_collection["features"].length do
            unless @geocodes.include? @feature_collection["features"][@i]["properties"]["geo_code_id"]
              @feature_collection["features"].delete_at(@i)
            else
              @i += 1
            end
          end
          render :json => @feature_collection
        end
      elsif params["search"].scan(/(?:\(.*?\))+/)[0].start_with?("(GEO")
        @searchGeoName = Geocode.solr_search do
          keywords params["search"].split(/(?:\(.*?\))+/)[0] do
            fields(:geo_name)
          end
          paginate :page => 1, :per_page => 10000
        end
        @geocodes = []
        @geocodes.concat(@searchGeoName.results.map(&:id))
        unless @feature_collection.nil?
          @i = 0
          while @i < @feature_collection["features"].length do
            unless @geocodes.include? @feature_collection["features"][@i]["properties"]["geo_code_id"]
              @feature_collection["features"].delete_at(@i)
            else
              @i += 1
            end
          end
          render :json => @feature_collection
        end
      else
        @search = Project.solr_search do
          keywords params["search"].split(/(?:\(.*?\))+/)[0] do
            fields(:description, :title => 2.0)
          end
          with :active_string, 'Active'
        end
        @full_result_ids = @search.results.map(&:id)
        unless @feature_collection.nil?
          @i = 0
          while @i < @feature_collection["features"].length do
            unless @full_result_ids.include? @feature_collection["features"][@i]["properties"]["project_id"]
              @feature_collection["features"].delete_at(@i)
            else
              @i += 1
            end
          end
          render :json => @feature_collection
        end
      end
    else
      render :json => @feature_collection
    end
  end

  def json_completion
    @search = Adm.solr_search do
      keywords params['keywords'].nil??nil:params['keywords']+' OR '+params['keywords']+'*' do
        fields(:name)
      end
    end
    @searchGeoName = GeoName.solr_search do
      keywords params['keywords'].nil??nil:params['keywords']+' OR '+params['keywords']+'*' do
        fields(:name)
      end
    end
    @i = 0
    @len = @searchGeoName.results.first(4).length
    @bucket = []
    @bucket << params['keywords'] + " (keyword)"
    while @i < @len
      @bucket << @searchGeoName.results[@i]["name"] + " (GEO: " + [@searchGeoName.results[@i]].map(&:location_type)[0]["name"] + ")"
      @i += 1
    end
    @i = 0
    @len = @search.results.first(5).length
    while @i < @len
      @bucket << @search.results[@i]["name"] + " (ADM" + @search.results[@i]["level"].to_s + ")"
      @i += 1
    end
    render :json => @bucket.flatten
  end

  def new_map
    render file: '/static_pages/new_map'
  end

  def signup
    render file: '/static_pages/signup'
  end

  # caches_action :recent, cache_path: "recent"
  # Make sure this gets expired in models/project_sweeper !
  def recent
    recent_projects = []
    first = Rails.cache.fetch "recent/first"
    second = Rails.cache.fetch "recent/second"
    third = Rails.cache.fetch "recent/third"

    recent_projects << first << second << third

    recent_projects.each do |entry|
      next if not entry
      entry[:time] = view_context.time_ago_in_words(entry[:time])
    end

    recent_projects.compact!

    render json: recent_projects

  end

  def recent_changes
    filtered_attribute = params[:filter]
    if filtered_attribute && !filtered_attribute.empty?
      @history = ProjectAssociationChange.where("attribute_name = ? OR association_model = ?", filtered_attribute,filtered_attribute)
                                         .order("created_at desc")
                                         .paginate(page: params[:page], per_page: 50)

    else
      @history = ProjectAssociationChange.order("created_at desc")
                                         .paginate(page: params[:page], per_page: 50)
    end
  end


  def ajax
    require 'open-uri'
    CGI::unescape request_url = params[:url]
    @data = open(request_url){|io| io.read}
    render text: @data
  end



  private

  def make_aggregator_locals()
    Proc.new { return {
      valid_field_options: AggregateValidators::VALID_FIELDS.map {|f| [f[:name], f[:external].to_s] }.sort { |a, b| a[1] <=> b[1] },
      where_filters: AggregateValidators::WHERE_FILTERS.select {|f| f[:name] != "Recipient ISO2"},
      duplication_handler_options: AggregateValidators::DUPLICATION_HANDLERS.map {|f| [f[:name], f[:external]] },
      duplication_handler_hints: AggregateValidators::DUPLICATION_HANDLERS.map {|f| [f[:external], f[:note] ] },
    }}.call
  end

end

