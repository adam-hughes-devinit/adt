class AddChineseContentToContents < ActiveRecord::Migration
  def change
    add_column :contents, :chinese_content, :text
  end
end
