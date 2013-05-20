class AddManyCodesToCountries < ActiveRecord::Migration
  def change
  	add_column :countries, :un_code, :integer
  	add_column :countries, :imf_code, :integer
  	add_column :countries, :aiddata_code, :integer
  end
end
