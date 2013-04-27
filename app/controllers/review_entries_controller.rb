class ReviewEntriesController < ApplicationController
  before_filter :aiddata_only!

  def index
    @review_entries = ReviewEntry.all
    @review_sections = {}
    @review_entries.each do |r|
      type = r.ar_model
      if not @review_sections.include?(type)
        @review_sections[type] = []
      end
      @review_sections[type] << r
    end

  end

  def show
    @review_entry = ReviewEntry.find(params[:id])
  end

  def destroy
    if params[:approve]
      @review_entry = ReviewEntry.find(params[:id])
      @item = @review_entry.item
      @item.save
    end
    ReviewEntry.destroy(params[:id])
    render :json => true
  end

end
