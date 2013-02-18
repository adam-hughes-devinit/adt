class ExportsController < ApplicationController
  def index

    @exports = Export.all
    # respond_to do |format|
    #    format.html {render template: 'shared/code_index', locals: {objects: @objects, type: @class_type.pluralize}}
    # end
  end

  def show
  end

  def new
  end

  def update
  end

  def create
  end
end
