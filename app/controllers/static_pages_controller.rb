class StaticPagesController < ApplicationController
skip_before_filter :signed_in_user
include SearchHelper
  def home
  	custom_search # to initialize facets, etc
  	@total_projects = Project.where("active = ?", true ).count
  	@feed = Version.last(10)
  end

  def help
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
