class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user
  include SearchHelper
  include AggregatesHelper
  require 'will_paginate/array'
  def home
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

  def codebook
    pdf_data = File.open(Rails.public_path + "/methodology/AidData_MBDC_Methodology_1.0.pdf", "r"){|io| io.read}
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

  def new_map
    render file: '/static_pages/new_map'
  end

  def signup
    render file: '/static_pages/signup'
  end

  # caches_action :recent, cache_path: "recent"
  # Make sure this gets expired in models/project_sweeper !
  def recent

    most_recent_project = Project.past_stage_one.where("active = 't'").limit(1).order("updated_at DESC").first
    if most_recent_project
      last_updated = most_recent_project.updated_at
      p last_updated
      recent_changes = Rails.cache.fetch "recent/#{last_updated}" do
        latest_changes = Project.past_stage_one
                                .where("active = 't'")
                                .order("updated_at ASC")
                                .last(3)

        recent_changes_data = latest_changes.reverse.map do |project|
          changes = project.changes
          update_sentence = "updated "
          # state the items that were updated
          if changes.size < 5
            update_sentence << changes.keys
                                      .map{|t| t.titleize}
                                      .map{|t| t.downcase}
                                      .join(', ')
          end
            json = {
              id: project.id,
              title: project.title,
              info: project.to_english(exclude_title: true),
              action: "#{update_sentence} #{view_context.time_ago_in_words(project.updated_at)} ago",
            }
        end
      end
    else
      recent_changes = {}
    end

    render json: recent_changes
  end

  def recent_changes
    @history = Version.where("item_type != ?", 'Comment')
                      .where("item_type != ? AND event != ?", 'Project', 'update')
                      .order("created_at desc")
                      .paginate(page: params[:page], per_page: 50)
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

