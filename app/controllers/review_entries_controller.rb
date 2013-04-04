class ReviewEntriesController < ApplicationController
  def index
    @review_entries = ReviewEntry.all
  end

  def show
    @review_entry = ReviewEntry.find(params[:id])
  end
end
