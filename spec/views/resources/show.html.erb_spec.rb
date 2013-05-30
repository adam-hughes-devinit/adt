require 'spec_helper'

describe "resources/show" do
  before(:each) do
    @resource = assign(:resource, stub_model(Resource,
      :title => "Title",
      :authors => "MyText",
      :publisher => "Publisher",
      :publisher_location => "Publisher Location",
      :download_url => "Download Url",
      :dont_fetch => false,
      :resource_type => "Resource Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
    rendered.should match(/Publisher/)
    rendered.should match(/Publisher Location/)
    rendered.should match(/Download Url/)
    rendered.should match(/false/)
    rendered.should match(/Resource Type/)
  end
end
