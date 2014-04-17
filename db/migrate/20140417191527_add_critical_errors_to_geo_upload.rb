class AddCriticalErrorsToGeoUpload < ActiveRecord::Migration
  def change
    add_column :geo_uploads, :critical_errors, :integer
  end
end
