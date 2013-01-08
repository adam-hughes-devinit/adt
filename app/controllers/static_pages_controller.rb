class StaticPagesController < ApplicationController
skip_before_filter :signed_in_user
include SearchHelper
include AggregatesHelper

  def home
  	custom_search # to initialize facets, etc
  	@total_projects = Project.where("active = ?", true ).count
  	@feed = Version.last(20)
  end

	def aggregator
		# Why can't I access the Aggregate constants in my view directly?

		render 'aggregate_exporter', locals: {
				valid_field_options: VALID_FIELDS.map {|f| [f[:name], f[:external].to_s] },
				where_filters: WHERE_FILTERS.select {|f| f[:name] != "Recipient ISO2"},
				duplication_handler_options: DUPLICATION_HANDLERS.map {|f| [f[:name], f[:external]] },
				duplication_handler_hints: DUPLICATION_HANDLERS.map {|f| [f[:external], f[:note] ] }
				}
	end

	def analyze
		render file: '/static_pages/_analyze_js'
	end

  def ajax
  	require 'open-uri'
  	CGI::unescape request_url = params[:url]
  	@data = open(request_url){|io| io.read}
  	render text: @data
  end

end
