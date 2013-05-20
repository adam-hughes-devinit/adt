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
    @review_entry = ReviewEntry.find(params[:id])
    was_approved = params[:approve]
    AiddataAdminMailer.delay.review_entry_notification(@review_entry, was_approved)

    if was_approved
      @item = @review_entry.item
      @item.save
    end
    
    @review_entry.destroy
    render :json => true
  end

end
