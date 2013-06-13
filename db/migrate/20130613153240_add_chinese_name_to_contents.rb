class AddChineseNameToContents < ActiveRecord::Migration
  def change
    add_column :contents, :chinese_name, :string
  end
end
