require 'spec_helper'

describe "verifieds/index" do
  before(:each) do
    assign(:verifieds, [
      stub_model(Verified,
        :name => "Name"
      ),
      stub_model(Verified,
        :name => "Name"
      )
    ])
  end

  it "renders a list of verifieds" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
