class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  include SearchHelper
  include GeospatialSearchHelper
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
    initialize_geospatial_dashboard

    respond_to do |format|
      format.html { render 'geospatial_dashboard' }
      format.json { render json: @page}
    end
  end

  def geospatial_search
    geospatial_search_ajax
  end

  def json_completion
    json_completion_ajax
  end

  def geo_paginated_search
    geo_paginated_search_ajax
  end

  def micro_project_page
    micro_project_page_ajax
  end

  def search_twitter
    search_twitter_ajax
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

