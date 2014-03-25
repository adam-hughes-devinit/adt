ActiveAdmin.register Content do
  menu :parent => "Content"

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Content" do
      f.input :name
      f.input :content, as: :html_editor
      f.input :chinese_name
      f.input :chinese_content, as: :html_editor
      f.input :searchable, :hint => "Check this if you want it to appear in the search bar"
    end
    f.buttons
  end
  
end
