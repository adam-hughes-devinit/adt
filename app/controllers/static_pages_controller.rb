class StaticPagesController < ApplicationController
skip_before_filter :signed_in_user
  def home
  	@feed = Version.all
  end

  def help
  end

  def vis
  end
end
