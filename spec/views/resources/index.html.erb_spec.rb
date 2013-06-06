require 'spec_helper'

describe "resources/index" do
  before(:each) do
    assign(:resources, [
      stub_model(Resource,
        :title => "Title",
        :authors => "MyText",
        :publisher => "Publisher",
        :publisher_location => "Publisher Location",
        :download_url => "Download Url",
        :dont_fetch => false,
        :resource_type => "Resource Type"
      ),
      stub_model(Resource,
        :title => "Title",
        :authors => "MyText",
        :publisher => "Publisher",
        :publisher_location => "Publisher Location",
        :download_url => "Download Url",
        :dont_fetch => false,
        :resource_type => "Resource Type"
      )
    ])
  end

  it "renders a list of resources" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Publisher".to_s, :count => 2
    assert_select "tr>td", :text => "Publisher Location".to_s, :count => 2
    assert_select "tr>td", :text => "Download Url".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Resource Type".to_s, :count => 2
  end
end
