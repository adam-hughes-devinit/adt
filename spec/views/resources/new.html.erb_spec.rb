require 'spec_helper'

describe "resources/new" do
  before(:each) do
    assign(:resource, stub_model(Resource,
      :title => "MyString",
      :authors => "MyText",
      :publisher => "MyString",
      :publisher_location => "MyString",
      :download_url => "MyString",
      :dont_fetch => false,
      :resource_type => "MyString"
    ).as_new_record)
  end

  it "renders new resource form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", resources_path, "post" do
      assert_select "input#resource_title[name=?]", "resource[title]"
      assert_select "textarea#resource_authors[name=?]", "resource[authors]"
      assert_select "input#resource_publisher[name=?]", "resource[publisher]"
      assert_select "input#resource_publisher_location[name=?]", "resource[publisher_location]"
      assert_select "input#resource_download_url[name=?]", "resource[download_url]"
      assert_select "input#resource_dont_fetch[name=?]", "resource[dont_fetch]"
      assert_select "input#resource_resource_type[name=?]", "resource[resource_type]"
    end
  end
end
