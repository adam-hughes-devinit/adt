class AddLogErrorsToGeoUpload < ActiveRecord::Migration
  def change
    add_column :geo_uploads, :log_errors, :integer
  end
end
