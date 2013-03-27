class StaticPagesController < ApplicationController
skip_before_filter :signed_in_user
include SearchHelper
include AggregatesHelper

  def home
  	custom_search # to initialize facets, etc
  	@total_projects = Project.where("active = ?", true ).count
  	@feed = Version.last(20)
  	@value_delimiter = VALUE_DELIMITER
  	@aggregator_locals = make_aggregator_locals
  end

	def aggregator
		@aggregator_locals = make_aggregator_locals
    @value_delimiter = VALUE_DELIMITER
		render 'aggregate_exporter_page'
	end

	def analyze
		render file: '/static_pages/_analyze_js'
	end

  def downloads
    render file: '/static_pages/_download_data'
  end

  def dashboard 
    render 'dashboard'
  end


  def ajax
  	require 'open-uri'
  	CGI::unescape request_url = params[:url]
  	@data = open(request_url){|io| io.read}
  	render text: @data
  end
  
  def caches
  	page = params[:page] || 1 
  	text = Cache.where("id != 0").limit(50).offset(((page.to_i-1)*50)).map { |c| c.text }
  	render json: text
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

