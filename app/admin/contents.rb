ActiveAdmin.register Content do
  menu :parent => "Content"

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Content" do
      f.input :content_type
      f.input :name
      f.input :content, as: :html_editor
      f.input :chinese_name
      f.input :chinese_content, as: :html_editor
    end
    f.buttons
  end
  
end
