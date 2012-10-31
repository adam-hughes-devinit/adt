class StaticPagesController < ApplicationController
skip_before_filter :signed_in_user
  def home
  	@total_projects = Project.where("active = ?", true ).count
  	@feed = Version.all
  end

  def help
  end

  def vis
  end
end
