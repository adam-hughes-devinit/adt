class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  include SearchHelper
  include AggregatesHelper

  def home
    render 'home'
  end

  def aggregator
    @aggregator_locals = make_aggregator_locals
    @value_delimiter = VALUE_DELIMITER
    render 'aggregate_exporter_page'
  end

  def analyze
    render 'bubbles'
  end

  def codebook
    send_file Rails.public_path + "/methodology/AidData_MBDC_Methodology_1.0.pdf"
  end

  def csv_analyzer
    render 'csv_analyzer'
  end

  def dashboard 
    render 'dashboard'
  end

  def map
    render 'map'
  end

  def new_map
    render file: '/static_pages/new_map'
  end

  def signup
    render file: '/static_pages/signup'
  end

  def recent
    render :partial => 'shared/recent'
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
      valid_field_options: VALID_FIELDS.map {|f| [f[:name], f[:external].to_s] }.sort { |a, b| a[1] <=> b[1] },
      where_filters: WHERE_FILTERS.select {|f| f[:name] != "Recipient ISO2"},
      duplication_handler_options: DUPLICATION_HANDLERS.map {|f| [f[:name], f[:external]] },
      duplication_handler_hints: DUPLICATION_HANDLERS.map {|f| [f[:external], f[:note] ] },
      wdi: WDI.map{ |w| [ w[:note], w[:code] ] }
    }}.call
  end

end

