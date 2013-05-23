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
    @content = ReviewEntry.find(params[:id])
  end

  def destroy
    @review_entry = ReviewEntry.find(params[:id])
    was_approved = params[:approve]

    if was_approved
      was_approved = true
      @item = @review_entry.item
      @item.save
    else
      was_approved = false
    end
    #TODO add delay
    AiddataAdminMailer.review_notification(@review_entry.dup, was_approved).deliver
    
    @review_entry.destroy
    render :json => true
  end

end
