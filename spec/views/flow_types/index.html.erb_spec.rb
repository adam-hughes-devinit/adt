require 'spec_helper'

describe "flow_types/index" do
  before(:each) do
    assign(:flow_types, [
      stub_model(FlowType,
        :name => "Name",
        :iati_code => 1,
        :aiddata_code => 2,
        :oecd_code => 3
      ),
      stub_model(FlowType,
        :name => "Name",
        :iati_code => 1,
        :aiddata_code => 2,
        :oecd_code => 3
      )
    ])
  end

  it "renders a list of flow_types" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
